%%%%%%%%%%%%%%%%%%%%%
% GROWTH ACCOUNTING %
%%%%%%%%%%%%%%%%%%%%%

% AUTHOR: SANKALP SHARMA 

% Set data directory
mdata = '/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/data';

% open US data
us_data = readtable(fullfile(mdata, 'us_clean.csv'));

% open UK data
uk_data = readtable(fullfile(mdata, 'uk_clean.csv'));