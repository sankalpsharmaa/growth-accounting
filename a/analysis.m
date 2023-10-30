%%%%%%%%%%%%%%%%%%%%%
% GROWTH ACCOUNTING %
%%%%%%%%%%%%%%%%%%%%%

% AUTHOR: SANKALP SHARMA 

% Set data directory
mdata = '/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/data';

% set output directory
out = '/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/tex/out'

% open US data
us_data = readtable(fullfile(mdata, 'us_clean.csv'));

% open UK data
uk_data = readtable(fullfile(mdata, 'uk_clean.csv'));

us_data.i_t = us_data.i_t ./ 1000
us_data.y_t =  us_data.y_t ./ 1000
us_data.dk_t = us_data.dk_t ./ 1000

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
print(savefig, fullfile(out, 'Investment'),'-dpdf','-r0')

% calculate capital-output ratio
us_data.depdata = us_data.dk_t ./ us_data.y_t;

% use arithmetic mean to calculate initial depreciation rate
us_delta = geomean(us_data.depdata);

% solve using arithmetic average (10 year mean)
geom = 0;

%Compute the function at the guess
fun = @(x) InitK(x, us_delta, us_data.y_t(1:10),us_data.i_t(1:10), geom); 

% specify an initial guess for K_t
Kguess = 20;

% calculate initial value of K_t
InitK(Kguess, us_delta, us_data.y_t(1:10),us_data.i_t(1:10), geom)

% fsolve takes the function fun  and an initial guess as input and gives the solution.  
[K0a10, fun] = fsolve(fun, Kguess);

% solve using arithmetic average (5 year mean)
geom = 0;

%Compute the function at the guess
fun = @(x) InitK(x, us_delta, us_data.y_t(1:5),us_data.i_t(1:5), geom); 

% specify an initial guess for K_t
Kguess = 100;

% calculate initial value of K_t
InitK(Kguess, us_delta, us_data.y_t(1:5),us_data.i_t(1:5), geom)

% fsolve takes the function fun  and an initial guess as input and gives the solution.  
[K0a5, fun] = fsolve(fun, Kguess);

% solve using geometric average (10 year mean)

%Compute the function at the guess
fun = @(x) InitK(x, us_delta, us_data.y_t(1:10),us_data.i_t(1:10), 1); 

% specify an initial guess for K_t
Kguess = 20;

% calculate initial value of K_t
InitK(Kguess, us_delta, us_data.y_t(1:10),us_data.i_t(1:10), 1)

% fsolve takes the function fun  and an initial guess as input and gives the solution.  
[K0g10, fun] = fsolve(fun, Kguess);

% Construct K_t and compare                        
% Given K0, compute the capital series 

% Compute Kt series
t_us  = length(us_data.y_t);

% make an array of zeros and merge with US data
Ka10  = zeros(1,t_us);
Ka5  = zeros(1,t_us);
Kg10  = zeros(1,t_us);

us_data.Ka10  = Ka10' ;
us_data.Ka5  = Ka5' ;
us_data.Kg10  = Kg10' ;

% Compute initial Capital
us_data.Ka10(1) = K0a10';
us_data.Ka5(1) = K0a5';
us_data.Kg10(1) = K0g10';

% compute capital levels using the capital accumulation equation 

% Compute the series
for t=2:t_us
    
    % Compute capital stock series for US
    us_data.Ka10(t)  = (1 - us_delta) * us_data.Ka10(t-1) + us_data.i_t(t) ;
    us_data.Ka5(t)  = (1 - us_delta) * us_data.Ka5(t-1) + us_data.i_t(t) ;
    us_data.Kg10(t)  = (1 - us_delta) * us_data.Kg10(t-1) + us_data.i_t(t) ;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% CALCULATE INITIAL K0 %

% Define the InitK function
function F = InitK(K0, delta, Y, I, geom)

    T = length(Y);

    % Initialize a vector to store capital levels
    K = zeros(1, T);  

    % Initialize the first element of the vector with K0
    K(1) = K0;  
    
    % Calculate subsequent capital levels
    for t = 2:T
        K(t) = (1 - delta) * K(t - 1) + I(t);  
    end
    
    % Calculate the capital-output ratios
    KY = K ./ Y;  
    
    % Calculate the output based on geometric average
    if geom == 1
        F = KY(1) - geomean(KY(2:end)) ;
    else

        % otherwise Calculate the output based on arithmetic average
        F = KY(1) - mean(KY(2:end));  
    end
end