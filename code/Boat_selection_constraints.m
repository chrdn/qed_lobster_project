function [c,ceq] = Boat_selection_constraints(design_variables)
%UNTITLED2 Summary of this function goes here
%   Constraints
Ht = design_variables(1); 
Hl = design_variables(2);
Et = design_variables([3,4]); % [diesel/gas, horsepower]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Input/outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
estimated_boat_cost = 1800008.83701111;
maintenance_cost = 1.8019e+05;
days_at_sea = 4 * 26; % days per week * weeks per season

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lobster_catch_threshold = 58000;
lobsters_per_mile = 10; % max 450 traps per day; offshore is about 45 miles
% expected_mpg = 4 for a 300 HP, 25'

expected_mpg_HP = -2/300*(Et(2)-300)+4; % scales by horsepower
expected_mpg_HL = -2/35*(Hl-25)+4; % scales by hull length

expected_mpg = mean([expected_mpg_HP,expected_mpg_HL]);

max_speed_length_ratio = 1.34;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Et(1)==1 % gasoline
    engine = 9000/300*(Et(2)-300)+1000; % scales with horsepower
    price_per_gallon = 7.5; 
    upfront = 9000/300*(Et(2)-300)+1000;
else % diesel
    engine = 35000/300*(Et(2)-300)+15000;
    price_per_gallon = 3.55;
    expected_mpg = expected_mpg * 1.5; % 50% more fuel efficient?
    upfront = 35000/300*(Et(2)-300)+15000;
end


% range of mile options: 10, 30, 50
% in shore, off shore, super off shore
base_distance_length = Hl*2-50; % in miles, (30,40,50)
base_distance_type = (Ht+2)*10*2-50; % planar hull, lobster boat, downeast hull (1,2,3)
range = min(base_distance_length,base_distance_type);
lobsters_caught_per_day = lobsters_per_mile * range;
lobster_catch = days_at_sea * lobsters_caught_per_day*3/4+21000; % range of lobster catch: 28800,44400,60000

boat = (1e6-1.25e5)/(20)*(Hl-30)+1.25e5;

b = 1.24;
A = (50000-10000)/b^(20);
dry_weight = A*b^(Hl-30)+10000; % 50' is 50000 lb, 30' is 10000 lb, 40' is 14000 lb
equipment_weight = 10000;
weight = dry_weight + equipment_weight;
max_hull_speed = max_speed_length_ratio * sqrt(Hl); 
lb_per_hp = (10.665/max_speed_length_ratio)^3;
hp_required = weight / lb_per_hp * 3; % FOS of 3


c(1) = engine + boat - estimated_boat_cost;
c(2) = sqrt(days_at_sea * (Ht/10) * Hl * (1+Et(1)) * Et(2))*5 - maintenance_cost; % gas engine requires more frequent repairs
% c(3) = 300/20*(Hl-30)+300-Et(2); % horsepower must be big enough for the hull length
c(3) = hp_required - Et(2); % updated horsepower - hull length relationship
c(4) = lobster_catch_threshold-lobster_catch; 
ceq = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%
% sources
%%%%%%%%%%%%%%%%%%%%%%%%
% - https://www.thehulltruth.com/boating-forum/503825-confused-about-hp-fishing-boat.html