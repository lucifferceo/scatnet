% Load a familiar tune & truncate to the first N samples.
N = 65536;
load handel;
y = y(1:N);

% Set up default filter bank with averaging scale of 4096 samples.
filt_opt = default_filter_options('audio', 4096);

% Only compute zeroth-, first- and second-order scattering.
scat_opt.M = 2;

% Prepare wavelet transforms to use in scattering.
Wop = wavelet_factory_1d(N, filt_opt, scat_opt);

% Compute the scattering coefficients of y.
S = scat(y, Wop);

% Display first-order coefficients, as a function of time and scale j1, and
% second-order coefficients for a fixed j1, as a function of time and second
% scale j2.
j1 = 23;
scattergram(S{2},[],S{3},j1);

% Renormalize second order by dividing it by the first order and compute the
% logarithm of the coefficients.
S = renorm_scat(S);
S = log_scat(S);

% Display the transformed coefficients.
scattergram(S{2},[],S{3},j1);
