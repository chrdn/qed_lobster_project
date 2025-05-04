 function [fuel_costs, lobster_catch]= Boat_selection(design_variables)
%   maximize lobster catch + minimize fuel costs

%   lobster catch = days at sea * #lobsters caught per day
%   #lobsters caught per day = lobsters per mile * range
    % #lobsters caught per day = min(#lobsters caught per day, hull length)
%   range given by hull type and hull length
%   fuel efficiency is given by horsepower and length (proxy for weight)
%   engine horsepower  has to "fit" hull length (constraint), used to calculate
    % fuel cost


%   Parameters
%   days at sea (fishing strategy)

%   s.t.
%   boat price has to be less than that given by BUSINESS
%   maintenance cost has to be less than that given by BUSINESS
%   engine type must "fit" for hull length (for hp)



%   boat price as a result of hull type, hull length, engine type
%   maintenance cost as a result of days at sea, hull type, and engine type




%   Design variables
Ht = design_variables(1); 
Hl = design_variables(2);
Et = design_variables([3,4]); % [diesel/gas, horsepower]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Input/outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
days_at_sea = 4 * 26; % days per week * weeks per season
hours_per_day = 12;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lobsters_per_mile = 10; % max 450 traps per day; offshore is about 45 miles
% expected_mpg = 4 for a 300 HP, 25'

expected_mpg_HP = -2/300*(Et(2)-300)+4; % scales by horsepower
expected_mpg_HL = -2/35*(Hl-25)+4; % scales by hull length

expected_mpg = mean([expected_mpg_HP,expected_mpg_HL]);


% GPH = (SFC x HP) / FSW
if Et(1)==1 % gasoline
    price_per_gallon = 7.5; 
    upfront = 9000/300*(Et(2)-300)+1000;
    expected_gph = (.5 * Et(2)) / 6.1;
else % diesel
    price_per_gallon = 3.55;
    expected_mpg = expected_mpg * 1.5; % 50% more fuel efficient?
    upfront = 35000/300*(Et(2)-300)+15000;
    expected_gph = (.4 * Et(2)) / 7.2;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% range of mile options: 10, 30, 50
% in shore, off shore, super off shore
base_distance_length = Hl*2-50; % in miles, (30,40,50)
base_distance_type = (Ht+2)*10*2-50; % planar hull, lobster boat, downeast hull (1,2,3)
range = min(base_distance_length,base_distance_type);
lobsters_caught_per_day = lobsters_per_mile * range;
lobster_catch = days_at_sea * lobsters_caught_per_day*3/4+21000; % range of lobster catch: 28800,44400,60000


% fuel costs is annual fuel costs
% fuel cost is fuel used on a single trip
% fuel_cost_daily = range / expected_mpg * price_per_gallon; % gallons_used * ppg, where gallons_used = m / mpg
fuel_cost_daily = expected_gph * hours_per_day * price_per_gallon;
fuel_costs = days_at_sea * fuel_cost_daily;


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% calculation sources: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - https://www.ingmanmarine.com/article/calculating-fuel-consumption#:~:text=A%20simpler%2C%20yet%20less%20accurate,hour%20at%20wide%2Dopen%20throttle.