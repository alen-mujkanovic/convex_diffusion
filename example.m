% This script serves as an example to compare diffusion encoding gradient
% waveforms generated by an analytical method creating symmetric
% waveforms against a convex optimization method generating concomitant
% field corrected asymmetric waveforms
% Settings and targets can be adapted as suited in parameters.m

%% Initialize
path = fileparts(which(mfilename));
addpath(genpath(path))
resultsFile = '';		% Filename for saving results to disk

%% Create waveforms
% Design symmetric waveform
sym = symmetricDiffusion;

% Design convex waveform
nTop = round(sym.nE-sym.param.nRead/2);	% Encoding duration upper bound
nBot = sym.param.nRF;					% Encoding duration lower bound
cvx = convexDiffusion(nBot, nTop);

%% Calculate and display results
sym = finalResults(sym);
fprintf(['Non-optimized: ' sym.info '\n']);
cvx = finalResults(cvx);
fprintf(['Optimized    : ' cvx.info '\n']);

% Create plots
plotMoments(sym, cvx);
plotPhase(sym, cvx);

% Save to disk
if ~strcmp(resultsFile,"")
	save (resultsFile, 'sym', 'cvx');
end