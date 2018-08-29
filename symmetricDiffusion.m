function sym = symmetricDiffusion
% Returns the tE for symmetric DWI waveforms with a specified b-value and
% sequence timing parameters. The waveforms are constructed using:
%		Monopolar pulse pair for M0 nulled
%		Bipolar pulse pair for M0/M1 nulled
%		Modified bipolar pair for M0/M1/M2 nulled (Stoeck et al, MRM 2015)
%
% Output:	sym		Output waveform data structure

%% Initialize
% Create data structures
sym = struct();
sym.param = parameters('sym');
p = sym.param;	% Shorthand access to parameters
dt = p.dt;		% Easy access for frequent use

% Initialize
tRamp = p.Gmax/p.Smax;			% Gradient ramp time [s]
tRamp = ceil(tRamp/p.dt)*p.dt;	% Round with to nearest full timestep
nRamp = ceil(tRamp/p.dt);		% Normalized ramp time
N = round(4e-3/p.dt);			% Minimal lobe duration in timesteps
b = 0;							% Initialize b

%%  Design symmetric waveform
while (b <= p.bTarget*0.99)		% Repeat until the b-value is large enough

	% Increment lobe duration
	N = N + 1;

	% Create G(t) vector from lobe durations
	switch p.MMT
		case 0 % Monopolar pair
			G = trapTransform([N,N],p.Gmax,nRamp,1,p.nRF,1);
		case 1 % Bipolar pair
			G = trapTransform([N,-N,N,-N],p.Gmax,nRamp,1,p.nRF,2);
		case 2 % Modified bipolar pair
			N2  = 2*N + nRamp;
			G = trapTransform([N,-N2,-N2,N],p.Gmax,nRamp,1,p.nRF,2);
	end

	% Test b-value
	nEnc = length(G);
	p.inv.n = round(nEnc/2);
	b = bValue(G, p);

end

%% Set final values
% Scale gradient to target b-value
sym.G = scaleGmax(G, p);
sym.b = bValue(sym.G, p);

% Add pre-time to waveform
sym.G = [zeros(round(p.nRead/2),1); sym.G];
sym.n = numel(sym.G);

% Lengths and durations
sym.nPre = round(p.nRead/2);				sym.tPre = sym.nPre * dt;
sym.nEnc = nEnc;							sym.tEnc = sym.nEnc * dt;
sym.nPost = 0;								sym.tPost = sym.nPost * dt;
sym.nInv = round(sym.nEnc/2 + sym.nPre);	sym.tInv = sym.nInv * dt;
sym.param.inv.n = sym.nInv;						
sym.nE = 2 * sym.nInv;						sym.tE = sym.nE * dt;