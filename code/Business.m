function [f, net_profit, revenue_breakdown, cost_breakdown] = Business(x, fishing_revenue)
    % x = [rs1, maintenance, loan_term, rs2, price_per_pound, capital, license_choice, rental_days, rs3, sales_strategy, license_tier]

    % Economic parameters
    maintenance_cost_per_week = 500;
    rental_income_per_day = 900;
    interest_rate = 0.08;

    % Extract decision variables
    lobster_on     = x(1);
    maintenance    = x(2);
    loan_term      = x(3);
    capital_cost   = x(6);
    rental_days    = x(8);
    rental_on      = x(9);
    direct         = x(10);
    license_tier   = x(11);

    % Licensing info
    lobster_pot_limits    = [200, 400, 800];
    lobster_license_costs = [17000, 35000, 55000];
    cod_license_cost      = 10000;
    scallop_license_cost  = 12000;

    lobster_pots = lobster_pot_limits(license_tier + 1);
    lobster_license_cost = lobster_license_costs(license_tier + 1);
    fish_license_cost = (cod_license_cost + scallop_license_cost) * (fishing_revenue > 0);
    license_cost = lobster_license_cost + fish_license_cost;

    % Distribution strategy
    if direct
        price_per_pound = 38;
        labor_cost_per_lobster = 2;
    else
        price_per_pound = 22;
        labor_cost_per_lobster = 0;
    end

    % Labor calculations
    days_per_week = 6;
    raw_weeks = 8 * lobster_on;
    weeks_active = min(12, raw_weeks);
    total_lobsters = lobster_on * lobster_pots * days_per_week * weeks_active;
    total_labor_cost = labor_cost_per_lobster * total_lobsters;

    % Revenue
    lobster_days = 273 - 127 + 1;
    revenue_lobster = lobster_on * lobster_pots * price_per_pound * (lobster_days / 7);
    revenue_rental  = rental_on * rental_days * rental_income_per_day;

    if nargin < 2
        revenue_fish = 0;
    else
        revenue_fish = fishing_revenue;
    end

    total_revenue = revenue_lobster + revenue_fish + revenue_rental;

    % Maintenance & Loan
    total_maintenance = max(maintenance * (25 / 7) * maintenance_cost_per_week, 5000);
    loan_payment = capital_cost * (interest_rate * (1 + interest_rate)^loan_term) / ((1 + interest_rate)^loan_term - 1);
    total_loan_cost = loan_payment * loan_term;

    % Costs and Net profit
    total_costs = total_maintenance + license_cost + total_loan_cost + total_labor_cost;
    net_profit = total_revenue - total_costs;

    % Output
    revenue_breakdown = struct('Lobster', revenue_lobster, 'Fish', revenue_fish, 'Rental', revenue_rental);
    cost_breakdown = struct('Maintenance', total_maintenance, 'Licenses', license_cost, 'Loan', total_loan_cost, 'Labor', total_labor_cost);

    realism_penalty = (1 - maintenance / 1e6) + (1 - license_cost / 5.5e4);
    f = -net_profit + realism_penalty * 1000;
end
