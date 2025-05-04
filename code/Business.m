function f = Business(x)
    % x = [rs1, maintenance, loan_term, rs2, price_per_pound, capital, license_cost, rental_days, rs3, sales_strategy]

    % basic parameters for fishing and sales
    trap_yield = 600; % lobsters caught per day
    price_wholesale = 30; % $ per pound for wholesale
    price_direct = 45; % $ per pound for direct-to-customer
    maintenance_cost_per_week = 500; % weekly maintenance cost
    rental_income_per_day = 1000; % charter rental income per day
    interest_rate = 0.08; % annual interest rate for loan

    % extract decision variables
    lobster_on = x(1); % 1 if lobster fishing is active
    maintenance = x(2); % maintenance interval
    loan_term = x(3); % number of years for loan
    fish_on = x(4); % 1 if other fishing is active
    capital_cost = x(6); % initial capital for boat
    license_cost = x(7); % cost of license and regulations
    rental_days = x(8); % number of off-season rental days
    rental_on = x(9); % 1 if doing charter rentals
    direct = x(10); % 1 if selling direct-to-customer

    % adjust price and add labor cost if using direct-to-customer strategy
    if direct
        price_per_pound = price_direct;
        labor_cost_per_lobster = 5; % assumed cost to clean/package each lobster
        lobsters_per_day = trap_yield;
        days_per_week = 6;
        weeks_active = 8 * (lobster_on + fish_on); % total fishing weeks
        total_lobsters = lobsters_per_day * days_per_week * weeks_active;
        total_labor_cost = labor_cost_per_lobster * total_lobsters;
    else
        price_per_pound = price_wholesale;
        total_labor_cost = 0;
    end

    % revenue from each stream
    revenue_lobster = lobster_on * trap_yield * price_per_pound * 8; % 8 weeks of lobster
    revenue_fish = fish_on * trap_yield * price_per_pound * 8; % 8 weeks of fish
    revenue_rental = rental_on * rental_days * rental_income_per_day; % charter rental revenue
    total_revenue = revenue_lobster + revenue_fish + revenue_rental;

    % maintenance cost based on how often maintenance is done
    total_maintenance = maintenance * (25 / 7) * maintenance_cost_per_week;

    % calculate loan payments using standard annuity formula
    loan_payment = capital_cost * (interest_rate * (1 + interest_rate)^loan_term) / ...
                   ((1 + interest_rate)^loan_term - 1);
    total_loan_cost = loan_payment * loan_term;

    % sum up all costs
    total_costs = total_maintenance + license_cost + total_loan_cost + total_labor_cost;

    % calculate net profit
    net_profit = total_revenue - total_costs;

    % penalty to discourage unrealistic values (e.g., minimal license/maintenance)
    realism_penalty = (1 - maintenance / 1e6) + (1 - license_cost / 5.5e4);

    % objective function to minimize (negative profit plus penalty) neg
    % null form
    f = -net_profit + realism_penalty * 1000;
end
