function external = wingCreateExternal( n_panel )

% Disclamer:
%   SPDX-License-Identifier: GPL-2.0-only
% 
%   Copyright (C) 2020-2022 Yannic Beyer
%   Copyright (C) 2022 TU Braunschweig, Institute of Flight Guidance
% *************************************************************************

% external additional wind concentrated vectors in body frame, m/s
external.V_Wb = zeros( 3, n_panel );
% external additional time-derivative of wind in body frame, m/s
external.V_Wb_dt = zeros( 3, n_panel );
% atmosphere struct
external.atmosphere = isAtmosphere(0);

end