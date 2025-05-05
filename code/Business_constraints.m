function [c, ceq] = Business_constraints(x)
    % Extract variables from x
    loan_term    = x(3);
    capital_cost = x(6);
    rental_days  = x(8);  % fixed from x(7) to x(8)

    % Constants
    interest_rate = 0.08;
    boat_limit    = 2e6;   % $2 million limit
    max_rental    = 60;

    % Calculate total boat cost using annuity-like formula
    true_boat_cost = capital_cost * (1.08^loan_term - 1) / log(1.08);

    % Constraints
    c(1) = true_boat_cost - boat_limit;   % Boat cost must stay under budget
    c(2) = rental_days - max_rental;      % Rental days must stay within allowed

    % No equality constraints
    ceq = [];
end
