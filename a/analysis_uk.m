%%%%%%%%%%%%%%%%%%%%%
% GROWTH ACCOUNTING %
%%%%%%%%%%%%%%%%%%%%%

% AUTHOR: SANKALP SHARMA 

% Set data directory
mdata = '/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/data';

% set output directory
out = '/Users/sankalpsharma/Library/CloudStorage/GoogleDrive-ssharma9@usc.edu/My Drive/fall-2023/macro/macro-pset-4/growth-accounting/tex/out';

% open US data
us_data = readtable(fullfile(mdata, 'us_clean.csv'));

% open UK data
uk_data = readtable(fullfile(mdata, 'uk_clean.csv'));

uk_data.i_t = uk_data.i_t ./ 1000000;
uk_data.y_t =  uk_data.y_t ./ 1000000;
uk_data.dk_t = uk_data.dk_t ./ 100000;
uk_data.cn = uk_data.cn ./ 10000000;

% construct investment-GDP ratio
us_data.IY = us_data.i_t * 100 ./ us_data.y_t;
uk_data.IY = uk_data.i_t * 100 ./ uk_data.y_t;

savefig = figure;

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
print(savefig, fullfile(out, 'Investment_uk'),'-dpdf','-r0')

% calculate capital-output ratio
uk_data.depdata = uk_data.dk_t ./ uk_data.y_t;

% use arithmetic mean to calculate initial depreciation rate
uk_delta = geomean(uk_data.depdata);

% solve using arithmetic average (10 year mean)
geom = 0;

%Compute the function at the guess
fun = @(x) InitK(x, uk_delta, uk_data.y_t(1:10),uk_data.i_t(1:10), geom); 

% specify an initial guess for K_t
Kguess = 20;

% calculate initial value of K_t
InitK(Kguess, uk_delta, uk_data.y_t(1:10),uk_data.i_t(1:10), geom)

% fsolve takes the function fun  and an initial guess as input and gives the solution.  
[K0a10, fun] = fsolve(fun, Kguess);

% solve using arithmetic average (5 year mean)
geom = 0;

%Compute the function at the guess
fun = @(x) InitK(x, uk_delta, uk_data.y_t(1:5),uk_data.i_t(1:5), geom); 

% specify an initial guess for K_t
Kguess = 100;

% calculate initial value of K_t
InitK(Kguess, uk_delta, uk_data.y_t(1:5),uk_data.i_t(1:5), geom)

% fsolve takes the function fun  and an initial guess as input and gives the solution.  
[K0a5, fun] = fsolve(fun, Kguess);

% solve using geometric average (10 year mean)

%Compute the function at the guess
fun = @(x) InitK(x, uk_delta, uk_data.y_t(1:10),uk_data.i_t(1:10), 1); 

% specify an initial guess for K_t
Kguess = 20;

% calculate initial value of K_t
InitK(Kguess, uk_delta, uk_data.y_t(1:10),uk_data.i_t(1:10), 1)

% fsolve takes the function fun  and an initial guess as input and gives the solution.  
[K0g10, fun] = fsolve(fun, Kguess);

% Construct K_t and compare                        
% Given K0, compute the capital series 

% Compute Kt series
t_us  = length(uk_data.y_t);

% make an array of zeros and merge with US data
Ka10  = zeros(1,t_us);
Ka5  = zeros(1,t_us);
Kg10  = zeros(1,t_us);

uk_data.Ka10  = Ka10' ;
uk_data.Ka5  = Ka5' ;
uk_data.Kg10  = Kg10' ;

% Compute initial Capital
uk_data.Ka10(1) = K0a10';
uk_data.Ka5(1) = K0a5';
uk_data.Kg10(1) = K0g10';

% compute capital levels using the capital accumulation equation 

% Compute the series
for t=2:t_us
    
    % Compute capital stock series for US
    uk_data.Ka10(t)  = (1 - uk_delta) * uk_data.Ka10(t-1) + uk_data.i_t(t) ;
    uk_data.Ka5(t)  = (1 - uk_delta) * uk_data.Ka5(t-1) + uk_data.i_t(t) ;
    uk_data.Kg10(t)  = (1 - uk_delta) * uk_data.Kg10(t-1) + uk_data.i_t(t) ;

end

% make comparison table 
Corrus = [corr(uk_data.Ka10,uk_data.Ka10) corr(uk_data.Ka10,uk_data.Kg10) corr(uk_data.Ka10,uk_data.Ka5)]';
SDus   = [std(uk_data.Ka10)/std(uk_data.Ka10)  std(uk_data.Kg10)/std(uk_data.Ka10) std(uk_data.Ka5)/std(uk_data.Ka10)]';
Gratesus = [uk_data.Ka10 uk_data.Kg10 uk_data.Ka5];
Gratesus = mean(log(Gratesus(2:end,:)) -log(Gratesus(1:end-1,:)));
Gratesus = (Gratesus./Gratesus(1))';

%Add rownames and colnames
rowNames   = {'Correlation','Relative SD','Average Growth Rate'};
colNames   = {'10yr avg','10 geom avrg', '5-year avrg'};
Table1   = array2table([Corrus SDus Gratesus]','RowNames',rowNames,'VariableNames',colNames)

%Now, lets plot!!
 
savefig = figure;

%Plot USA
subplot(2,1,1);
plot(uk_data.year, uk_data.Kg10);
hold on
plot(uk_data.year, uk_data.Ka10);
hold on
plot(uk_data.year, uk_data.Ka5);

xlabel ( 'Years','Interpreter','latex' ) ;
ylabel ( 'Trillions of Pounds','Interpreter','latex' ) ;
title ( '$K_{t}$ In UK','Interpreter','latex' ) ;
legend('10y Geom','10y Arithm','5y Arithm','Interpreter','latex','Location','Southeast')

%Save Output to pdf
set(savefig,'Units','Inches');
pos = get(savefig,'Position');
set(savefig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(savefig, fullfile(out, 'Capital_Series_uk'),'-dpdf','-r0')

%Now, lets plot the PWT comp
 
savefig = figure;

%Plot USA
subplot(2,1,1);
plot(uk_data.year, uk_data.Kg10);
hold on
plot(uk_data.year, uk_data.Ka10);
hold on
plot(uk_data.year, uk_data.Ka5);
hold on
plot(uk_data.year, uk_data.cn);
xlabel ( 'Years','Interpreter','latex' ) ;
ylabel ( 'Trillions of \$USD','Interpreter','latex' ) ;
title ( '$K_{t}$ In UK','Interpreter','latex' ) ;
legend('10y Geom','10y Arithm','5y Arithm','PWT','Interpreter','latex','Location','Southeast')

%% Question 1-3: capital share of income
% Recall that the capital share of income is defined by 
% $\alpha_t = 1-\frac{CE_t}{Y_t-(HHGOS_t-HHCC_t) - (T_t-S_t)}$

%Use the literature value instead
alpha = 1/3

%% Question 1-4: growth accounting 

%First, lets compute labor series
uk_data.L   = uk_data.h_t.*uk_data.pop_t;
uk_data.YN  = uk_data.y_t ./ uk_data.pop_t;

%Remember(Y_t/N_t) = A_t^(1/(1-alpha)) (K_t/Y_t)^(alpha/(1-alpha)) L_t/N_t
%Compute TFP == A_t
%I will use the capital from the arithmetic average using 10 obs
uk_data.A  = ( (uk_data.y_t ./ uk_data.pop_t) ./ ((uk_data.Ka10 ./ uk_data.y_t).^(alpha/(1-alpha)).* uk_data.L ./ uk_data.pop_t) ).^(1-alpha);
 
%Now lets do the growth accounting (take growth rates)
uk_data.GAlev = [uk_data.YN uk_data.A.^(1/(1-alpha))  (uk_data.Ka10 ./ uk_data.y_t).^(alpha/(1-alpha))  uk_data.L ./ uk_data.pop_t]; 

% we can change the 1 here to a different value ie 20 to change starting year
uk_data.GAlev  = uk_data.GAlev(1:end,:);

%Now take logs
uk_data.GAlog  = log(uk_data.GAlev );

% Calculate the growth rates
GA  = (uk_data.GAlog(2:end,:) -  uk_data.GAlog(1:end-1,:))*100;

%Now take historic averages
GAh  = mean(GA);

%Now print the GA
savefig = figure;

%Plot UK
subplot(2,1,1);
plot(uk_data.year(2:end), GA);
xlabel ( 'Years','Interpreter','latex' ) ;
ylabel ( 'Growth Rate (\%)','Interpreter','latex' ) ;
title ( 'Growth Accounting In UK','Interpreter','latex' ) ;
legend('$\widehat{\frac{Y}{N}}$','$\frac{\widehat{A}}{1-\alpha}$','$\frac{\alpha}{1-\alpha}\widehat{\frac{K}{Y}}$','$\widehat{\frac{L}{N}}$','Interpreter','latex','Location','Southeast','Orientation','horizontal')

%Save Output to pdf
set(savefig,'Units','Inches');
pos = get(savefig,'Position');
set(savefig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(savefig,fullfile(out, 'Growth_Accounting_us'),'-dpdf','-r0')

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