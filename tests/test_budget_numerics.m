function tests = test_budget_numerics
%TEST_BUDGET_NUMERICS Regression tests for tracer-budget calculations.

    tests = functiontests(localfunctions);
end

function testWindStressCurlLinearField(testCase)
    lat = (-10:10)';
    lon = 120:130;
    R = 6371000;
    [LON, LAT] = meshgrid(lon, lat);
    x = deg2rad(LON) .* R .* cos(deg2rad(LAT));

    curl = wsc(lat, lon, zeros(size(x)), x);
    verifyEqual(testCase, curl, ones(size(curl)), 'AbsTol', 5e-13);
end

function testEquatorialCoriolisMask(testCase)
    lat = [-5, -2.5, 0.5, 3.5];
    [f, valid] = masked_coriolis(lat, 3);

    verifyEqual(testCase, valid, [true; false; false; true]);
    verifyTrue(testCase, all(isnan(f(~valid))));
    verifyTrue(testCase, all(isfinite(f(valid))));
end

function testCenteredMonthlyChangeUsesCalendarDuration(testCase)
    time = (datetime(2020, 1, 1):calmonths(1):datetime(2021, 12, 1))';
    month_center = dateshift(time, 'start', 'month') + ...
        days(eomday(year(time), month(time)) / 2);
    elapsed = seconds(month_center - month_center(1));
    data = reshape(elapsed, 1, 1, []);

    actual = centered_monthly_change(data, time);
    expected = reshape(seconds_per_month(time), 1, 1, []);

    verifyTrue(testCase, isnan(actual(1, 1, 1)));
    verifyTrue(testCase, isnan(actual(1, 1, end)));
    verifyEqual(testCase, actual(:, :, 2:end-1), ...
        expected(:, :, 2:end-1), 'RelTol', 1e-14);
end

function testFixedLayerMeanIncludesSurfaceToFirstLevel(testCase)
    pres = [5; 10];
    data = reshape([5, 10], 1, 1, 2);

    actual = fixed_layer_mean(data, pres, 2);

    % 0-5 dbar is held at 5; 5-10 dbar is linearly integrated.
    verifyEqual(testCase, actual, 6.25, 'AbsTol', 1e-14);
end

function testAnnualAggregationRequiresCoverage(testCase)
    grid.lon = (1:3)';
    grid.lat = 1;
    grid.time = ...
        (datetime(2020, 1, 1):calmonths(1):datetime(2021, 12, 1))';

    data.raw = ones(3, 1, 24);
    data.raw(2, 1, :) = NaN;
    data.raw(3, 1, 10:12) = NaN;   % 9 valid months in 2020
    data.raw(3, 1, 23:24) = NaN;   % 10 valid months in 2021

    result = anomaly(data, grid, 'Sum', true, 'MinAnnualMonths', 10);

    verifyTrue(testCase, all(isnan(result.ysum(2, 1, :))));
    verifyTrue(testCase, isnan(result.ysum(3, 1, 1)));
    verifyEqual(testCase, result.ysum(3, 1, 2), 0, 'AbsTol', 1e-14);
end

function testBudgetClosureUsesOneCommonMask(testCase)
    grid.lon = (1:2)';
    grid.lat = 1;
    grid.time = ...
        (datetime(2020, 1, 1):calmonths(1):datetime(2021, 12, 1))';
    shape = [2, 1, 24];

    budget.tendency.raw = 10 .* ones(shape);
    budget.surface_forcing.raw = 2 .* ones(shape);
    budget.entrainment.raw = 3 .* ones(shape);
    budget.advection_zonal.raw = ones(shape);
    budget.advection_meridional.raw = 4 .* ones(shape);
    budget.surface_forcing.raw(2, 1, 1) = NaN;

    result = finalize_tracer_budget(budget, grid, 12);

    verifyTrue(testCase, isnan(result.tendency.raw(2, 1, 1)));
    verifyTrue(testCase, isnan(result.rhs_total.raw(2, 1, 1)));
    verifyEqual(testCase, result.rhs_total.raw(1, 1, :), ...
        result.tendency.raw(1, 1, :), 'AbsTol', 1e-14);
    verifyEqual(testCase, result.residual.raw(1, 1, :), ...
        zeros(1, 1, 24), 'AbsTol', 1e-14);
    verifyTrue(testCase, isnan(result.rhs_total.ysum(2, 1, 1)));
    verifyEqual(testCase, result.residual.ysum(1, 1, :), ...
        zeros(1, 1, 2), 'AbsTol', 1e-14);
end
