function [c, ceq] = Business_constraints(x)
    % c is the vector of inequality constraints (c <= 0)
    % ceq is the vector of equality constraints (ceq == 0)

    % extract variables
    loan_term = x(3);
    capital_cost = x(6);
    license_cost = x(7);
    rental_days = x(8);

    % calculate true boat cost using annuity loan formula
    % this is a more realistic total amount paid over time
    interest_rate = 0.08;
    true_boat_cost = capital_cost * (1.08^loan_term - 1) / log(1.08);
    boat_limit = 2000000;

    % minimum licensing requirement
    min_license = 17000;

    % marina restriction on rental days
    max_rental = 60;

    % inequality constraints
    c1 = true_boat_cost - boat_limit;     % total boat cost must be ≤ limit
    c2 = min_license - license_cost;      % license must be ≥ minimum
    c3 = rental_days - max_rental;        % rental days must be ≤ allowed

    % collect all constraints in c
    c = [c1; c2; c3];

    % no equality constraints
    ceq = [];
end
