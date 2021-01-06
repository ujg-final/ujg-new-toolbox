function idx = amo(sst,t,varargin)
% amo calculates the Atlantic Multidecadal Oscillation index from sea surface
% temperatures based on the definition proposed by Enfield et al. 2001. 
% 
%% Syntax 
% 
%  idx = amo(sst,t) 
%  idx = amo(sst,t,lat,lon)
% 
%% Description 
% 
% idx = amo(sst,t) calculates AMO index from a time series of 
% sea surface temperatures sst and their corresponding times t. 
% sst can be a vector of sea surface temperatures that have been
% averaged over a region of interest, or sst can be a 3D matrix whose third
% dimension correponds to times t. If sst is a 3D matrix, a time series is
% automatically generated by averaging all the grid cells in sst for each
% time step. Usually, the AMO is calculated from the area-weighted average
% of SSTs in the northern Atlantic from 0-70ºN.
%
% idx = amo(sst,t,lat,lon) calculates the AMO index for 3D sst time
% series and corresponding grid coordinates lat,lon. Using this syntax,
% grid cells within the AMO region are automatically determined and
% the AMO index is calculated from the area-averaged time series of ssts
% within that region. 
%
%% Examples
% For examples and a description of methods, type 
% 
%   cdt amo
%
%% Reference
% 
% Enfield, D.B., A.M. Mestas-Nunez, and P.J. Trimble, 2001: The 
% Atlantic Multidecadal Oscillation and its relationship to rainfall and 
% river flows in the continental U.S., Geophys. Res. Lett., 28: 2077-2080.
% 
%% Author Info
% This function was written by Kaustubh Thirumalai of the University of 
% Arizona, January 2019.
% http://www.kaustubh.info
% 
% See also: enso, nao, sam

%% Initial error checks: 

narginchk(2,Inf) 
assert(ismember(length(t),size(sst))==1,'Error: length of t must match dimensions of sst.') 

%% Parse inputs and obtain weighted sst:    

% Convert time from datetime, datestr, or datevec:
t = datenum(t); % (If it's already datenum, nothing changes.)

if nargin>2
    Lat = varargin{1};
    Lon = varargin{2};
    assert(~isvector(Lat),'Error: lat,lon grids must be matrices as if generated by meshgrid or cdtgrid.')
    assert(isequal(size(Lat),size(Lon),[size(sst,1) size(sst,2)]),'Error: Dimensions of Lat, Lon, and the sst grid must all agree.')
    
    % Define the AMO region's mask if lat/lon are given
    latrange = [0 70];
    lonrange = [-75 5];
    mask = geomask(Lat,Lon,latrange,lonrange);   
    
    % Get the area-weighted time series when lat/lon are given
    A = cdtarea(Lat,Lon);
    sst = local(sst,mask,'weight',A,'omitnan');
else 
    % if there are only two inputs, we want to average across the board
    mask = true(size(sst,1),size(sst,2)); 
    sst = local(sst,mask,'omitnan');
end

%% Calculate AMO index: 

% The pre-moving-averaged index is just the sst anomaly: 
idx = deseason(sst,t,'detrend','linear') - mean(sst,'omitnan');

% Detrend the anomalies:
idx  = detrend(idx,'linear');

end

