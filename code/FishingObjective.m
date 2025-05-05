function [neg_profit, total_revenue, net_profit_fish] = FishingObjective(x)
    % x = [crew_cut_lobster, crew_cut_cod, crew_cut_scallop]

    % Constants
    LL = 800; CL = 15; SL = 2000;
    gph = 10;
    dist_type = 0;
    days_in_year = 365;

    % Prices
    if dist_type == 1
        lobster_price = 22; cod_price = 10; scallop_price = 9;
    else
        lobster_price = 38; cod_price = 20; scallop_price = 16;
    end

    % Per-species productivity and profit
    prod_l = 100 * x(1) * log(1.3);
    yield_l = prod_l * 1.5 * (LL / 3);
    revenue_l = yield_l * lobster_price;
    labor_l = revenue_l * x(1);
    fuel_l = gph * 10 * 4 * 6 * 21;
    profit_l = revenue_l - labor_l - fuel_l;

    prod_c = 100 * x(2) * log(1.25);
    yield_c = prod_c * 20 * 18;
    revenue_c = yield_c * cod_price;
    labor_c = revenue_c * x(2);
    fuel_c = gph * 10 * 4 * 6 * 9;
    profit_c = revenue_c - labor_c - fuel_c;

    prod_s = 100 * x(3) * log(1.08);
    yield_s = prod_s * SL;
    revenue_s = yield_s * scallop_price;
    labor_s = revenue_s * x(3);
    fuel_s = gph * 10 * 4 * 6 * 18;
    profit_s = revenue_s - labor_s - fuel_s;

    % Max allowable days per species
    max_lobster = 273 - 127 + 1;
    max_cod     = 304 - 244 + 1;
    max_scallop = 273 - 152 + 1;

    lobster_days_used = 0;
    cod_days_used = 0;
    scallop_days_used = 0;

    total_profit = 0;
    daily_profit = zeros(days_in_year, 1);

    for i = 1:days_in_year
        choices = [];
        profits = [];

        % If lobster is in season and available
        if i >= 127 && i <= 273 && lobster_days_used < max_lobster
            profits(end+1) = profit_l;
            choices(end+1) = 1;
        end

        % If cod is in season and available
        if i >= 244 && i <= 304 && cod_days_used < max_cod
            profits(end+1) = profit_c;
            choices(end+1) = 2;
        end

        % If scallop is in season and available
        if i >= 152 && i <= 273 && scallop_days_used < max_scallop
            profits(end+1) = profit_s;
            choices(end+1) = 3;
        end

        if ~isempty(profits)
            [best_profit, idx] = max(profits);
            chosen = choices(idx);
            total_profit = total_profit + best_profit;
            daily_profit(i) = best_profit;

            switch chosen
                case 1
                    lobster_days_used = lobster_days_used + 1;
                case 2
                    cod_days_used = cod_days_used + 1;
                case 3
                    scallop_days_used = scallop_days_used + 1;
            end
        end
    end
    total_revenue = revenue_l + revenue_c + revenue_s;
    net_profit_fish = total_profit;
    neg_profit = -total_profit;

    % Optional plots
    if nargout == 0
        subplot(2,1,1);
        plot_fishing_productivity(x, yield_l, yield_c, yield_s);

        subplot(2,1,2);
        bar(1:days_in_year, daily_profit, 'FaceColor', [0.3 0.6 0.8]);
        xlabel('Day of Year');
        ylabel('Daily Profit ($)');
        title('Profit Per Day (Best Option Chosen)');
        grid on;
    end
end

function plot_fishing_productivity(x, y_l, y_c, y_s)
    pay_range = linspace(0.02, 0.2, 500);
    plot(pay_range*100, 100*log(1.3)*1.5*(800/3)*pay_range, 'r', 'LineWidth', 2); hold on;
    plot(pay_range*100, 100*log(1.25)*20*18*pay_range, 'g', 'LineWidth', 2);
    plot(pay_range*100, 100*log(1.08)*2000*pay_range, 'b', 'LineWidth', 2);
    plot(x(1)*100, y_l, 'ro', 'MarkerSize', 8);
    plot(x(2)*100, y_c, 'go', 'MarkerSize', 8);
    plot(x(3)*100, y_s, 'bo', 'MarkerSize', 8);
    xlabel('Crew Cut (%)'); ylabel('Yield (Lbs)');
    title('Yield vs. Crew Cut');
    legend('Lobster', 'Cod', 'Shellfish', 'Location', 'southeast');
    grid on;
end
