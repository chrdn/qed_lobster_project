function [fuel_costs, lobster_catch] = internal_Boat_selection(design_variables)
    % Inputs:
    % Ht = hull type [1=planar, 2=lobster, 3=downeast]
    % Hl = hull length (ft)
    % Et = [engine type (0=diesel, 1=gasoline), horsepower]

    % Extract design variables
    Ht = design_variables(1); 
    Hl = design_variables(2); 
    Et = design_variables([3, 4]); % [engine_type, horsepower]

    % Constants
    days_at_sea = 6 * 21;           % 6 days/week × 21 weeks (lobster season)
    hours_per_day = 10;             % hours fished per day
    lobsters_per_mile = 8;          % slightly more conservative than 10
    lobsters_per_trap = 2;        % yield per trap

    % Fuel Efficiency Estimates
    expected_mpg_HP = -2/300 * (Et(2) - 300) + 4; 
    expected_mpg_HL = -2/35 * (Hl - 25) + 4;
    expected_mpg = mean([expected_mpg_HP, expected_mpg_HL]);

    % Fuel settings
    if Et(1) == 1  % Gasoline
        price_per_gallon = 6.0;    % updated for realism
        expected_gph = (0.5 * Et(2)) / 6.1;
    else           % Diesel
        price_per_gallon = 4.0;
        expected_mpg = expected_mpg * 1.5; % 50% fuel bonus for diesel
        expected_gph = (0.4 * Et(2)) / 7.2;
    end

    % Range (miles/day)
    range_length = Hl * 2 - 50; 
    range_type = (Ht + 1) * 10 + 10;  % 20/30/40
    range = min(range_length, range_type); 

    % Catch Calculation
    traps_set = range * lobsters_per_mile;
    catch_per_day = traps_set * lobsters_per_trap;
    lobster_catch = catch_per_day * days_at_sea;

    % Fuel Cost Calculation
    daily_fuel_use = expected_gph * hours_per_day;
    fuel_costs = daily_fuel_use * price_per_gallon * days_at_sea;
end
