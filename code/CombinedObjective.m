function [f, net_profit_total] = CombinedObjective(x)
    % Extract variable groups
    business_vars = x(1:11);
    fishing_vars  = x(12:14);
    boat_vars     = x(15:18);

    % Boat selection
    [fuel_cost, lobster_limit] = internal_Boat_selection(boat_vars);

    % Fishing strategy
    [fish_obj, fishing_revenue, net_profit_fish] = FishingObjective(fishing_vars);

    % Business
    [business_obj, net_profit_business, ~, ~] = Business(business_vars, fishing_revenue);

    % Total negative objective
    f = business_obj + fish_obj + 0.01 * fuel_cost;

    % True net profit for display
    net_profit_total = net_profit_business + net_profit_fish;
end
