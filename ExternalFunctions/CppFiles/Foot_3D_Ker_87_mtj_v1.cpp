/*  This code describes the OpenSim model and the skeleton dynamics
Author: Antoine Falisse
Contributor: Joris Gillis, Gil Serrancoli, Chris Dembia

Adapted to describe the experiment done by Ker et al in 1987.
Author: Lars D'Hondt
*/
#include <OpenSim/Simulation/Model/Model.h>
#include <OpenSim/Simulation/SimbodyEngine/PlanarJoint.h>
#include <OpenSim/Simulation/SimbodyEngine/SliderJoint.h>
#include <OpenSim/Simulation/SimbodyEngine/PinJoint.h>
#include <OpenSim/Simulation/SimbodyEngine/WeldJoint.h>
#include <OpenSim/Simulation/SimbodyEngine/Joint.h>
#include <OpenSim/Simulation/SimbodyEngine/SpatialTransform.h>
#include <OpenSim/Simulation/SimbodyEngine/CustomJoint.h>
#include <OpenSim/Common/LinearFunction.h>
#include <OpenSim/Common/Constant.h>
#include <OpenSim/Common/SimmSpline.h>
#include <OpenSim/Simulation/Model/ConditionalPathPoint.h>
#include <OpenSim/Simulation/Model/MovingPathPoint.h>
#include <OpenSim/Simulation/Model/HuntCrossleyForce_smooth.h>
#include "SimTKcommon/internal/recorder.h"

#include <iostream>
#include <iterator>
#include <random>
#include <cassert>
#include <algorithm>
#include <vector>
#include <fstream>

using namespace SimTK;
using namespace OpenSim;

/*  The function F describes the OpenSim model and, implicitly, the skeleton
dynamics. F takes as inputs joint positions and velocities (states x),
joint accelerations (controls u), and returns the joint torques as well as
several variables for use in the optimal control problems. F is templatized
using type T. F(x,u)->(r).
*/

// Inputs/outputs of function F
/// number of vectors in inputs/outputs of function F
constexpr int n_in = 2;
constexpr int n_out = 1;
/// number of elements in input/output vectors of function F
constexpr int ndof = 14;           // # degrees of freedom (excluding locked)
constexpr int ndofr = ndof;    // # degrees of freedom (including locked)
constexpr int NX = ndof * 2;       // # states
constexpr int NU = ndof;           // # controls
constexpr int NR = ndof + 5 * 3 + 6;   // # joint origins + GRFs

									   // Helper function value
template<typename T>
T value(const Recorder& e) { return e; }
template<>
double value(const Recorder& e) { return e.getValue(); }


// Function F
template<typename T>
int F_generic(const T** arg, T** res) {

	// OpenSim model: create components
	/// Model
	OpenSim::Model* model;
	/// Bodies
	OpenSim::Body* tibia_r; // Only small part of tibia remains.
	OpenSim::Body* talus_r;
	OpenSim::Body* calcn_r;
	OpenSim::Body* central_foot_r; // This is the fusion of metatarsi, cuboid, navicular and cuneiform bones and their surrounding tissue.
	OpenSim::Body* toes_r;
	/// Joints
	OpenSim::CustomJoint* ground_tibia;
	OpenSim::CustomJoint* ankle_r;
	OpenSim::CustomJoint* subtalar_r;
	OpenSim::PinJoint* midtarsal_r;
	OpenSim::PinJoint* mtp_r;
	OpenSim::SliderJoint* ground_heel; // Heel is stripped to the bone.
	OpenSim::PlanarJoint* ground_forefoot; // Simplified ground contact

	// Inertia of the exoskeleton for right side
	Vec3 COMTibia = Vec3(0, -0.01, 0);
	Vec3 COMTalus = Vec3(0, 0, 0);
	osim_double_adouble mTibia = 0; 
	osim_double_adouble mTalus = 0.07750561734071933;
	Inertia ITibia(0, 0, 0, 0, 0, 0);
	Inertia ITalus(0.000647371, 0.000647371, 0.000647371, 0, 0, 0);

	// using different way to scale foot model

	// OpenSim model: initialize components
	/// Model
	model = new OpenSim::Model();
	/// Body specifications
	tibia_r = new OpenSim::Body("tibia_r", mTibia, COMTibia, ITibia);
	talus_r = new OpenSim::Body("talus_r", mTalus, COMTalus, ITalus);
	calcn_r = new OpenSim::Body("calcn_r", 0.4217, Vec3(0.03628, 0.017101, -0.004057), Inertia(8.5663e-05, 1.7507e-04, 2.0122e-04, 0, 0, 0));
	central_foot_r = new OpenSim::Body("central_foot_r", 0.5417, Vec3(0.03937, -0.01465, 0.0018528), Inertia(0.0013620, 0.002204, 0.0019264, 0, 0, 0));
	toes_r = new OpenSim::Body("toes_r", 0.16787716715999804, Vec3(0.03967, -0.01104, 0.00185), Inertia(6.2714132461258e-005, 0.000125428264922516, 6.2714132461258e-005, 0, 0, 0));
	/// Joints
	/// Ground-Tibia transform
	SpatialTransform st_ground_tibia;
	st_ground_tibia[0].setCoordinateNames(OpenSim::Array<std::string>("tibia_tilt", 1, 1));
	st_ground_tibia[0].setFunction(new LinearFunction());
	st_ground_tibia[0].setAxis(Vec3(0, 0, 1));
	st_ground_tibia[1].setCoordinateNames(OpenSim::Array<std::string>("tibia_list", 1, 1));
	st_ground_tibia[1].setFunction(new LinearFunction());
	st_ground_tibia[1].setAxis(Vec3(1, 0, 0));
	st_ground_tibia[2].setCoordinateNames(OpenSim::Array<std::string>("tibia_rotation", 1, 1));
	st_ground_tibia[2].setFunction(new LinearFunction());
	st_ground_tibia[2].setAxis(Vec3(0, 1, 0));
	st_ground_tibia[3].setCoordinateNames(OpenSim::Array<std::string>("tibia_tx", 1, 1));
	st_ground_tibia[3].setFunction(new LinearFunction());
	st_ground_tibia[3].setAxis(Vec3(1, 0, 0));
	st_ground_tibia[4].setCoordinateNames(OpenSim::Array<std::string>("tibia_ty", 1, 1));
	st_ground_tibia[4].setFunction(new LinearFunction());
	st_ground_tibia[4].setAxis(Vec3(0, 1, 0));
	st_ground_tibia[5].setCoordinateNames(OpenSim::Array<std::string>("tibia_tz", 1, 1));
	st_ground_tibia[5].setFunction(new LinearFunction());
	st_ground_tibia[5].setAxis(Vec3(0, 0, 1));
	/// Ankle_r transform
	SpatialTransform st_ankle_r;
	st_ankle_r[0].setCoordinateNames(OpenSim::Array<std::string>("ankle_angle_r", 1, 1));
	st_ankle_r[0].setFunction(new LinearFunction());
	st_ankle_r[0].setAxis(Vec3(-0.10501355, -0.17402245, 0.97912632));
	/// Subtalar_r transform
	SpatialTransform st_subtalar_r;
	st_subtalar_r[0].setCoordinateNames(OpenSim::Array<std::string>("subtalar_angle_r", 1, 1));
	st_subtalar_r[0].setFunction(new LinearFunction());
	st_subtalar_r[0].setAxis(Vec3(0.78717961, 0.60474746, -0.12094949));
	
	/// Joint specifications
	ground_tibia = new CustomJoint("ground_tibia", model->getGround(), Vec3(0), Vec3(0), *tibia_r, Vec3(0), Vec3(0), st_ground_tibia); // 6 dof
	ankle_r = new CustomJoint("ankle_r", *tibia_r, Vec3(0, -0.02, 0), Vec3(0), *talus_r, Vec3(0), Vec3(0), st_ankle_r); // 1 dof
	subtalar_r = new CustomJoint("subtalar_r", *talus_r, Vec3(-0.044572100000000003, -0.05145, 0.0072382799999999997), Vec3(0), *calcn_r, Vec3(0), Vec3(0), st_subtalar_r); // 1 dof
	midtarsal_r = new PinJoint("midtarsal_r", *calcn_r, Vec3(0.078023, 0.025452, -0.0068103), Vec3(0), *central_foot_r, Vec3(0), Vec3(0)); // 1 dof
	mtp_r = new PinJoint("mtp_r", *central_foot_r, Vec3(0.0853859, -0.02728, 0.00779737), Vec3(0), *toes_r, Vec3(0), Vec3(0)); // 1 dof
	ground_heel = new SliderJoint("ground_heel", model->getGround(), Vec3(0, 0.010, 0), Vec3(0), *calcn_r, Vec3(0.06, -0.01, 0.012), Vec3(0)); // 1 dof
	ground_forefoot = new PlanarJoint("ground_forefoot", model->getGround(), Vec3(0), Vec3(-1.5708, 0, 0), *central_foot_r, Vec3(0.086976, -0.035452,  0.012), Vec3(-1.5708, 0, 0)); // 3 dof

	/// Add bodies and joints to model
	
	model->addBody(tibia_r);		model->addJoint(ground_tibia);
	model->addBody(talus_r);		model->addJoint(ankle_r);
	model->addBody(calcn_r);		model->addJoint(subtalar_r);
	model->addBody(central_foot_r);	model->addJoint(midtarsal_r);
	model->addBody(toes_r);		    model->addJoint(mtp_r);
	model->addJoint(ground_heel);	model->addJoint(ground_forefoot);

	// Initialize system and state
	SimTK::State* state;
	state = new State(model->initSystem());

	// Read inputs
	std::vector<T> x(arg[0], arg[0] + NX);
	std::vector<T> u(arg[1], arg[1] + NU);

	// States and controls
	T ua[ndof]; /// joint accelerations (Qdotdots)
	Vector QsUs(NX); /// joint positions (Qs) and velocities (Us) - states

						 // Assign inputs to model variables
						 /// States
	for (int i = 0; i < NX; ++i) QsUs[i] = x[i];
	/// Controls
	for (int i = 0; i < ndof; ++i) ua[i] = u[i];

	// Set state variables and realize
	model->setStateVariableValues(*state, QsUs);
	model->realizeVelocity(*state);

	// Compute residual forces
	/// appliedMobilityForces (# mobilities)
	Vector appliedMobilityForces(ndofr);
	appliedMobilityForces.setToZero();
	/// appliedBodyForces (# bodies + ground)
	Vector_<SpatialVec> appliedBodyForces;
	int nbodies = model->getBodySet().getSize() + 1;
	appliedBodyForces.resize(nbodies);
	appliedBodyForces.setToZero();
	/// Set gravity
	Vec3 gravity(0);
	gravity[1] = -9.81;
	/// Add weights to appliedBodyForces
	for (int i = 0; i < model->getBodySet().getSize(); ++i) {
		model->getMatterSubsystem().addInStationForce(*state,
			model->getBodySet().get(i).getMobilizedBodyIndex(),
			model->getBodySet().get(i).getMassCenter(),
			model->getBodySet().get(i).getMass()*gravity, appliedBodyForces);
	}
	

	/// knownUdot
	Vector knownUdot(ndofr);
	knownUdot.setToZero();
	for (int i = 0; i < ndofr; ++i) knownUdot[i] = ua[i];

	/// Calculate residual forces
	Vector residualMobilityForces(ndofr);
	residualMobilityForces.setToZero();
	model->getMatterSubsystem().calcResidualForceIgnoringConstraints(*state,
		appliedMobilityForces, appliedBodyForces, knownUdot,
		residualMobilityForces);

	// Extract several joint origins to set constraints in problem
	Vec3 calcn_or_r = calcn_r->getPositionInGround(*state);
	Vec3 tibia_or_r = tibia_r->getPositionInGround(*state);
	Vec3 toes_or_r = toes_r->getPositionInGround(*state);
	Vec3 central_foot_or_r = central_foot_r->getPositionInGround(*state);
	Vec3 talus_or_r = talus_r->getPositionInGround(*state);

	// Get ground reaction forces
	SpatialVec GRF_heel = ground_heel->calcReactionOnChildExpressedInGround(*state);
	SpatialVec GRF_forefoot = ground_forefoot->calcReactionOnChildExpressedInGround(*state);

	// Extract results
	int nc = 3;

	/// Residual forces (14)
	for (int i = 0; i < ndof; ++i) res[0][i] = value<T>(residualMobilityForces[i]);

	/// Joint origins tibia (3)
	for (int i = 0; i < nc; ++i) {
		res[0][i + ndof] = value<T>(tibia_or_r[i]);
	}

	/// Joint origins tibia (3)
	for (int i = 0; i < nc; ++i) {
		res[0][i + ndof + nc] = value<T>(talus_or_r[i]);
	}

	/// Joint origins - calcaneus (3)
	for (int i = 0; i < nc; ++i) {
		res[0][i + ndof + nc * 2] = value<T>(calcn_or_r[i]);
	}

	/// Joint origins - calcaneus (3)
	for (int i = 0; i < nc; ++i) {
		res[0][i + ndof + nc * 3] = value<T>(central_foot_or_r[i]);
	}

	/// Joint origins toes (3)
	for (int i = 0; i < nc; ++i) {
		res[0][i + ndof + nc * 4] = value<T>(toes_or_r[i]);
	}

	/// GRF heel (3)
	for (int i = 0; i < nc; ++i) {
		res[0][i + ndof + nc * 5] = value<T>(GRF_heel[1][i]);
	}

	/// GRF forefoot (3)
	for (int i = 0; i < nc; ++i) {
		res[0][i + ndof + nc * 6] = value<T>(GRF_forefoot[1][i]);
	}

	return 0;

}

/* In main(), the Recorder is used to save the expression graph of function F.
This expression graph is saved as a MATLAB function named foo.m. From this
function, a c-code can be generated via CasADi and then compiled as a dll. This
dll is then imported in MATLAB as an external function. With this workflow,
CasADi can use algorithmic differentiation to differentiate the function F.
*/
int main() {

	Recorder x[NX];
	Recorder u[NU];
	Recorder tau[NR];

	for (int i = 0; i < NX; ++i) x[i] <<= 0;
	for (int i = 0; i < NU; ++i) u[i] <<= 0;

	const Recorder* Recorder_arg[n_in] = { x,u };
	Recorder* Recorder_res[n_out] = { tau };

	F_generic<Recorder>(Recorder_arg, Recorder_res);

	double res[NR];
	for (int i = 0; i < NR; ++i) Recorder_res[0][i] >>= res[i];

	Recorder::stop_recording();

	return 0;

}