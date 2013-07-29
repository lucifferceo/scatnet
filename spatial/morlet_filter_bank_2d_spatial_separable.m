% morlet_filter_bank_2d : Build a bank of Morlet wavelet filters
%
% Usage
%	filters = morlet_filter_bank_2d(size_in, options)
%
% Input
% - size_in : <1x2 int> size of the input of the scattering
% - options : [optional] <1x1 struct> contains the following optional fields
%   - Q          : <1x1 int> the number of scale per octave
%   - J          : <1x1 int> the total number of scale.
%   - L   : <1x1 int> the number of orientations
%   - sigma_phi  : <1x1 double> the width of the low pass phi_0
%   - sigma_psi  : <1x1 double> the width of the envelope
%                                   of the high pass psi_0
%   - xi_psi     : <1x1 double> the frequency peak
%                                   of the high_pass psi_0
%   - slant_psi  : <1x1 double> the excentricity of the elliptic
%  enveloppe of the high_pass psi_0 (the smaller slant, the larger
%                                      orientation resolution)
%   - margins    : <1x2 int> the horizontal and vertical margin for
%                             mirror pading of signal
%
% Output
% - filters : <1x1 struct> contains the following fields
%   - psi.filter{p}.type : <string> 'fourier_multires'
%   - psi.filter{p}.coefft{res+1} : <?x? double> the fourier transform
%                          of the p high pass filter at resolution res
%   - psi.meta.k(p,1)     : its scale index
%   - psi.meta.theta(p,1) : its orientation scale
%   - phi.filter.type     : <string>'fourier_multires'
%   - phi.filter.coefft
%   - phi.meta.k(p,1)
%   - meta : <1x1 struct> global parameters of the filter bank

function filters = morlet_filter_bank_2d_spatial_separable(options)
	
	options.null = 1;
	
	Q = getoptions(options, 'Q', 1); % number of scale per octave
	L = getoptions(options, 'L', 8); % number of orientations
	
	sigma_phi  = getoptions(options, 'sigma_phi',  0.8);
	sigma_psi  = getoptions(options, 'sigma_psi',  0.8);
	xi_psi     = getoptions(options, 'xi_psi',  1/2*(2^(-1/Q)+1)*pi);
	
	
	P = getoptions(options, 'P', 3) % the size of the support is 2*P + 1
	
	% low pass filter h
	filter_spatial= gabor_2d(2*P+2,...
		2*P+2,...
		sigma_phi,...
		1,...
		0,...
		0,...
		[0,0]);
	tmp = fftshift(filter_spatial);
	tmp = tmp(2:2*P+2, 2:2*P+2);
	h.filter.coefft{1} = tmp(:,P+1);
	h.filter.coefft{2} = tmp(:,P+1);
	h.filter.type = 'spatial_support_separable';
	
	angles = (0:L-1)  * pi / L;
	p = 1;
	
	% high pass filters g
	for q = 0:Q-1
		for theta = 1:numel(angles)
			
			angle = angles(theta);
			scale = 2^(q/Q);
			
			tmp = morlet_2d_spatial(P, ...
				sigma_psi*scale,...
				1,...
				xi_psi/scale,...
				angle) ;
			
			g.filter{p}.coefft{1} = tmp(:,P+1);
			g.filter{p}.coefft{2} = transp(tmp(P+1,:));
			g.filter{p}.type = 'spatial_support_separable';
			
			g.meta.q(p) = q;
			g.meta.theta(p) = theta;
			p = p + 1;
			
		end
	end
	
	filters.h = h;
	filters.g = g;
	
	filters.meta.Q = Q;
	filters.meta.L = L;
	filters.meta.sigma_phi = sigma_phi;
	filters.meta.sigma_psi = sigma_psi;
	filters.meta.xi_psi = xi_psi;
	filters.meta.P = P;
	
	
end