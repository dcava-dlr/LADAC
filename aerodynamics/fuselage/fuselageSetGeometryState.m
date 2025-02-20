function fuselage = fuselageSetGeometryState( fuselage, modal_pos_state, ...
    varargin ) %#codegen
% fuselageSetGeometryState set state.geometry struct in fuselage struct
%   If the fuselage is flexible, the geometry can be adjusted during the
%   simulation. Not only the position of the nodes are changed but also the
%   velocity and the acceleration are computed based on the structure
%   state.
% 
% Syntax:
%   fuselage = fuselageSetGeometryState( fuselage, modal_pos_state )
%   fuselage = fuselageSetGeometryState( fuselage, modal_pos_state, ...
%       'structure_vel', modal_vel_state )
%   fuselage = fuselageSetGeometryState( fuselage, modal_pos_state, ...
%       'structure_vel', modal_vel_state, 'structure_accel', modal_accel )
% 
% Inputs:
%   fuselage            fuselage struct (see fuselageInit)
%   modal_pos_state     structure deformation vector in modal coordinates
%   modal_vel_sate      structure velocity vector in modal coordinates
%   modal_accel         structure acceleration vector in modal coordinates
% 
% Outputs:
%   fuselage            fuselage struct (see fuselageInit)
% 
% See also:
%   fuselageInit, fuselageCreate, structureCreateFromNastran
% 

% Disclamer:
%   SPDX-License-Identifier: GPL-2.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

is_structure_vel = false;
is_structure_accel = false;

for i = 1:length(varargin)
    if strcmp(varargin{i},'structure_vel')
        modal_vel_state = varargin{i+1};
        is_structure_vel = true;
    elseif strcmp(varargin{i},'structure_accel')
        modal_accel = varargin{i+1};
        is_structure_accel = false;
    end
end

% assign to struct
Delta_pos = fuselage.aeroelasticity.T_cs * modal_pos_state;
fuselage.state.geometry.cntrl_pos(:) = fuselage.geometry.cntrl_pos(:) + ...
    Delta_pos;
fuselage.state.geometry.border_pos(:) = fuselage.geometry.border_pos(:) + ...
    ( [ 2*Delta_pos(1:3);Delta_pos] + [ Delta_pos;2*Delta_pos(end-2:end) ] )/2;
fuselage.state.geometry.alpha(:) = fuselage.geometry.alpha + ...
    (fuselage.aeroelasticity.T_as * modal_pos_state)';
fuselage.state.geometry.beta(:) = fuselage.geometry.beta + ...
    (fuselage.aeroelasticity.T_Bs * modal_pos_state)';

% to do: derivative of alpha and beta
if is_structure_vel
    % time derivative of displacements
    cntrl_pos_dt = reshape( fuselage.aeroelasticity.T_cs * modal_vel_state, 3, [] );
    fuselage.state.geometry_deriv.border_pos_dt(:) = [ cntrl_pos_dt(:,1), ...
        cntrl_pos_dt(:,1:end-1) + diff(cntrl_pos_dt,1,2), cntrl_pos_dt(:,end) ];
end

end