function [state] = wingCreateState( num_actuators, n_panel, geometry )
%createState initializes wing.state struct for a wing struct
%
% Inputs:
% 	num_actuators           Number of actuators (scalar), in -
%   n_panel                 Number of panels (scalar), in -
%   geometry                wing.geometry struct of the wing struct (see
%                           wingSetGeometry)
%
% Outputs:
%    state                  Wing state struct (as defined by this function)
% 
% See also: wingCreate, wingSetGeometry
% 

% Disclamer:
%   SPDX-License-Identifier: GPL-2.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

%% rigid body states
% airspeed
state.body.V        = 100;
% angular velocity
state.body.omega    = zeros(3,1);
% aerodynamic angles (Should be interpreted as flight-path angles alpha_K
% and beta_K! The wind velocity is covered in "external".)
state.body.alpha    = 0;
state.body.beta     = 0;
% derivative of angular velocity vector (only relevant for unsteady
% aerodynamics)
state.body.omega_dt = zeros(3,1);
% derivative of the kinematic velocity vector (only relevant for unsteady
% aerodynamics)
state.body.V_Kb_dt  = zeros(3,1);

%% actuator states
state.actuators.pos          	= zeros( 1, num_actuators );
state.actuators.rate         	= zeros( 1, num_actuators );
state.actuators.segments.pos 	= zeros( 2, n_panel );
state.actuators.segments.rate 	= zeros( 2, n_panel );

%% aerodynamic states
% circulation variables
state.aero.circulation.gamma        = zeros( 1, n_panel );
state.aero.circulation.Gamma        = zeros( 1, n_panel );
state.aero.circulation.c_L          = zeros( 1, n_panel );
state.aero.circulation.c_L_flap     = zeros( 1, n_panel );
state.aero.circulation.delta_qs     = zeros( 1, n_panel );
state.aero.circulation.v_i          = zeros( 3, n_panel );
state.aero.circulation.alpha_eff	= zeros( 1, n_panel );
state.aero.circulation.alpha_ind    = zeros( 1, n_panel );
state.aero.circulation.Delta_alpha  = zeros( 1, n_panel );
state.aero.circulation.Re           = zeros( 1, n_panel );
state.aero.circulation.Ma           = zeros( 1, n_panel );
state.aero.circulation.num_iter 	= 0;
% rotation axes for VLM angle of attack correction
state.aero.circulation.rot_axis     = zeros( 3, n_panel );
% local coefficients
state.aero.coeff_loc.c_XYZ_b     	= zeros( 3, n_panel );
state.aero.coeff_loc.c_lmn_b        = zeros( 3, n_panel );
state.aero.coeff_loc.c_m_airfoil    = zeros( 1, n_panel );
% global coefficients
state.aero.coeff_glob.C_XYZ_b       = zeros(3,1);
state.aero.coeff_glob.C_lmn_b       = zeros(3,1);
% local velocity due to rotation
state.aero.local_inflow.V         	= zeros( 3, n_panel );
state.aero.local_inflow.alpha    	= zeros( 1, n_panel );
state.aero.local_inflow.beta     	= zeros( 1, n_panel );
state.aero.local_inflow.V_dt      	= zeros( 3, n_panel );

%% unsteady aerodynamics
% unsteady, transsonic aerodynamics
state.aero.unsteady.x_dt            = zeros( 8, n_panel );
state.aero.unsteady.x               = zeros( 8, n_panel );
% non-circulatory coefficients
state.aero.unsteady.c_L_nc          = zeros( 1, n_panel );
state.aero.unsteady.c_m_nc          = zeros( 1, n_panel );
% circulatory coefficients
state.aero.unsteady.c_L_c           = zeros( 1, n_panel );
state.aero.unsteady.c_m_c           = zeros( 1, n_panel );
state.aero.unsteady.c_D             = zeros( 1, n_panel );
state.aero.unsteady.alpha_eff       = zeros( 1, n_panel );
state.aero.unsteady.c_L_c_flap      = zeros( 1, n_panel );
% incuded normalized velocity vectors in body frame
state.aero.unsteady.v_i             = zeros( 3, n_panel );

% state for dynamic stall model
state.aero.unsteady.X_dt            = zeros( 3, n_panel );
state.aero.unsteady.X               = zeros( 3, n_panel );
% nondimensional time and its time derivative for leading edge separation (dynamic stall)
state.aero.unsteady.tau_v_dt        = zeros( 1, n_panel );
state.aero.unsteady.tau_v           = zeros( 1, n_panel );
% leading edge shock condition (dynamic stall)
state.aero.unsteady.is_leading_edge_shock = false( 1, n_panel );

% flap state
state.aero.unsteady.z_dt            = zeros( 2, n_panel );
state.aero.unsteady.z               = zeros( 2, n_panel );

% 2nd actuator state (first order delay)
state.aero.unsteady.z2_dt           = zeros( 1, n_panel );
state.aero.unsteady.z2              = zeros( 1, n_panel );

%% geometry
state.geometry = geometry;
state.geometry.ctrl_pt_dt = geometry.ctrl_pt;
state.geometry.ctrl_pt_dt = wingSetPosition( ...
    state.geometry.ctrl_pt_dt, zeros( n_panel*4, 1 ), 4, true );
state.geometry.ctrl_pt_dt2 = state.geometry.ctrl_pt_dt;

%% external
state.external = wingCreateExternal( n_panel );

end

