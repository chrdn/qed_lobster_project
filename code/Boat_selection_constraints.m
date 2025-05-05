function [c, ceq] = Boat_selection_constraints(design_variables)
    % Updated constraints for Boat Selection subsystem with cost realism

    % Inputs
    Ht = design_variables(1);       % Hull Type: 1=Planar, 2=Lobster, 3=Downeast
    Hl = design_variables(2);       % Hull Length (ft)
    Et = design_variables([3, 4]);  % Engine: [Type (0=Diesel, 1=Gas), Horsepower]

    % Constants
    days_at_sea = 6 * 21;                     % Active fishing days
    lobsters_per_mile = 10;                   % Traps per mile
    lobsters_per_trap = 1.5;                  % Catch per trap
    lobster_catch_threshold = 30000;          % Slightly lower threshold
    maintenance_cost_limit = 150000;          % Reduced from 180k
    boat_cost_limit = 1.5e6;                  % Reduced from 1.8M

    % Estimate mpg
    expected_mpg_HP = -2/300 * (Et(2) - 300) + 4;
    expected_mpg_HL = -2/35 * (Hl - 25) + 4;
    expected_mpg = mean([expected_mpg_HP, expected_mpg_HL]);

    % Fuel adjustments
    if Et(1) == 1  % Gasoline
        engine_cost = 9000/300 * (Et(2) - 300) + 1000;
        expected_gph = (0.5 * Et(2)) / 6.1;
    else           % Diesel
        engine_cost = 35000/300 * (Et(2) - 300) + 15000;
        expected_gph = (0.4 * Et(2)) / 7.2;
        expected_mpg = expected_mpg * 1.5;
    end

    % Boat cost estimate (scales with hull length)
    base_price = 125000;  % 30ft base
    boat_cost = (1e6 - base_price) / 20 * (Hl - 30) + base_price;

    % Range (limits based on hull and length)
    range_length = Hl * 2 - 50;
    range_type = (Ht + 1) * 10 + 10;
    range = min(range_length, range_type);

    % Estimated catch
    traps_set = lobsters_per_mile * range;
    catch_per_day = traps_set * lobsters_per_trap;
    lobster_catch = catch_per_day * days_at_sea;

    % Weight & horsepower requirements
    b = 1.24;
    A = (50000 - 10000) / b^20;
    dry_weight = A * b^(Hl - 30) + 10000;
    total_weight = dry_weight + 10000;  % Equipment
    S_L = 1.34;
    lb_per_hp = (10.665 / S_L)^3;
    hp_required = total_weight / lb_per_hp * 3;  % FOS = 3

    % Constraints
    c(1) = engine_cost + boat_cost - boat_cost_limit;              % Boat + engine ≤ limit
    c(2) = sqrt(days_at_sea * (Ht / 10) * Hl * (1 + Et(1)) * Et(2)) * 5 - maintenance_cost_limit;
    c(3) = hp_required - Et(2);                                    % Must meet HP requirement
    c(4) = lobster_catch_threshold - lobster_catch;                % Must meet lobster threshold

    ceq = [];
end
