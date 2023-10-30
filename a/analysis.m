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

% construct investment-GDP ratio
us_data.IY = us_data.i_t * 100 ./ us_data.y_t;
uk_data.IY = uk_data.i_t * 100 ./ uk_data.y_t;

savefig = figure

% Plot the series
plot (us_data.year, us_data.IY)
hold on 

plot (uk_data.year, uk_data.IY)
xlabel ( 'Year' ) ;
ylabel ( '(%)' ) ;
legend('USA','UK','Interpreter','latex')
title('$\frac{I_t}{Y_{t}}$','Interpreter','latex');

set(savefig,'Units','Inches');
pos = get(savefig,'Position');

set(savefig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(savefig,'Investment','-dpdf','-r0')