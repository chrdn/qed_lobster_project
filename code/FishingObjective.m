function neg_profit = FishingObjective(x, LL, CL, SL, gph, dist_type)
    % x = [lobster_hourly, cod_hourly, shellfish_hourly]
    % LL = 800;
    % CL = 20;
    % SL = 2000;
    % gph = 10;
    % dist_type = 0;
    lobster_lim = LL;
    cod_lim = CL;
    scallop_lim = SL;
    % constants
    trap_yield = lobster_lim / 3; %1/3 of the total traps 
    weight_lobster = 1.5; %Average lobster weight Lbs
    cod_weight = 18; %Average cod weight in Lbs
    cod_catch = cod_lim; %Typical daily yield per crew member
    scallop_yield = scallop_lim; % #Lbs

    fuel_gallons = gph; % Fuel consumption in gallons/per/hour
    gas_cost = 5; % Dollars per gallon of diesel
    fuel_cost = fuel_gallons * gas_cost; % fuel cost per hour

    crew_number = 3; % Number of crew members
    lobster_hours = 13; % Hours spent fishing for lobster
    cod_hours = 10; % Hours spent fishing for cod
    scallop_hours = 8; % Hours spent fishing for scallops

    hourly_lobster = 26; % Percentage of daily profit crew receives
    hourly_cod = 20;
    hourly_scallop = 26;

    ccl = x(1); % Percentage of daily profit crew receives
    ccc = x(2);
    ccs = x(3);

    days_in_year = 365;

    % distribution type
    distribution = dist_type; % 0 = direct-to-customer, 1 = wholesale

    % corrected price logic
    if distribution == 1
        lobster_price = 30;
        cod_price = 12;
        scallop_price = 10;
    else
        lobster_price = 35;
        cod_price = 20;
        scallop_price = 15;
    end

    % fishing seasons
    lobster_season = [127, 273];
    cod_season = [244, 304];
    scallop_season = [152, 273];


    % daily profits
    pay_lobster = crew_number * lobster_hours * hourly_lobster; % Cost of labor for lobster fishing
    prod_lobster = (100*ccl)*log(3); % Productivity which is dependent on pay
    lobster_yield = trap_yield * weight_lobster * prod_lobster; %lbs
    lobster_revenue = lobster_yield * lobster_price; 
    lobster_cost = fuel_cost*lobster_hours + pay_lobster;
    crew_cut_lobster = (lobster_revenue - lobster_cost)*crew_number*ccl;
    lobster_profit = lobster_revenue - lobster_cost - crew_cut_lobster;
    
    pay_cod = crew_number * cod_hours * hourly_cod; % Cost of labor for cod fishing
    prod_cod = (100*ccc)*log(1.25);
    cod_yield = cod_catch * cod_weight * prod_cod;
    cod_revenue = cod_yield * cod_price;
    cod_cost = fuel_cost*cod_hours + pay_cod;
    crew_cut_cod = (cod_revenue - cod_cost)*crew_number*ccc;
    cod_profit = cod_revenue - cod_cost - crew_cut_cod;

    pay_scallop = crew_number * scallop_hours * hourly_scallop; % Cost of labor for scallop fishing
    prod_scallop = (100*ccs)*log(2);
    scallop_yield = scallop_yield * prod_scallop;
    scallop_revenue = scallop_yield * scallop_price;
    scallop_cost = fuel_cost * scallop_hours + pay_scallop + scallop_revenue * ccs;
    crew_cut_scallop = (scallop_revenue - scallop_cost)*crew_number*ccs;
    scallop_profit = scallop_revenue - scallop_cost - crew_cut_scallop;

    % annual profit calculation
    total_profit = 0;
    for i = 1:days_in_year
        in_lobster = i >= lobster_season(1) && i <= lobster_season(2);
        in_cod = i >= cod_season(1) && i <= cod_season(2);
        in_scallop = i >= scallop_season(1) && i <= scallop_season(2);

        options = [];
        if in_lobster, options(end+1) = lobster_profit; end
        if in_cod, options(end+1) = cod_profit; end
        if in_scallop, options(end+1) = scallop_profit; end

        if ~isempty(options)
            total_profit = total_profit + max(options);
        end
    end

    neg_profit = -total_profit; % for minimization
end
