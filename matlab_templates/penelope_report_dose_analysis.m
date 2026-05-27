function penelope_report_dose_analysis
% PENELOPE report dose analysis helper (MATLAB R2015 compatible)
% 1) Reads the Excel table exported from body energy-deposition results.
% 2) Computes total dose per body and per ALPHA using quadrature errors.
% 3) Ranks angles by eye/tumor dose ratio.
% 4) Reads one 3d-dose.dat file and exports X/Y/Z profiles and XY/XZ/YZ dose planes.
%
% Edit paths below or choose files interactively.

close all;
clc;

%% ---------------- USER PARAMETERS ----------------
% Script-generated geometry label centres (cm)
%__STUDIO_SELECTED_LABELS_BEGIN__
xTumorOlhoDto = 4.0;  yTumorOlhoDto = 3.0;  zTumorOlhoDto = -2.2;
xOlhoDireito = 4.0;  yOlhoDireito = 6.5;  zOlhoDireito = -2.0;
xOlhoEsquerdo = -4.0;  yOlhoEsquerdo = 6.5;  zOlhoEsquerdo = -2.0;
selectedLabelSpecs = {
    {'Tumor olho dto', 'o', xTumorOlhoDto, yTumorOlhoDto, zTumorOlhoDto};
    {'Olho direito', 'x', xOlhoDireito, yOlhoDireito, zOlhoDireito};
    {'Olho esquerdo', 'x', xOlhoEsquerdo, yOlhoEsquerdo, zOlhoEsquerdo}
};
xT = xTumorOlhoDto;  yT = yTumorOlhoDto;  zT = zTumorOlhoDto;
%__STUDIO_SELECTED_LABELS_END__

% Files. Leave empty to choose interactively.
excelPath = '';
excelRoot = '';
dose3dPath = '';
dose3dRoot = '';

% Output folder. Leave empty to use the file folder.
outDir = '';

ced = [char(231) char(227)];
grau = char(176);

%% ---------------- PART A: BODY DOSE TOTALS FROM EXCEL ----------------
if isempty(excelPath) && isempty(excelRoot)
    excelMode = menu('Excel dose mode', 'One dose workbook', 'Scan root folder recursively', 'Skip');
    if excelMode == 1
        [f, p] = uigetfile({'*.xlsx;*.xls', 'Excel files'}, 'Select dose Excel file');
        if isequal(f, 0)
            disp('No Excel file selected; skipping body dose analysis.');
        else
            excelPath = fullfile(p, f);
        end
    elseif excelMode == 2
        rootChosen = uigetdir(pwd, 'Select root folder to scan recursively for dose workbooks');
        if isequal(rootChosen, 0)
            disp('No root folder selected; skipping recursive body dose analysis.');
        else
            excelRoot = rootChosen;
        end
    else
        disp('Skipping body dose analysis.');
    end
end

if ~isempty(excelRoot)
    excelFiles = collect_dose_workbooks_r2015(excelRoot);
    if isempty(excelFiles)
        disp(['No valid dose workbooks found under: ' excelRoot]);
    else
        processedExcel = 0;
        for i = 1:numel(excelFiles)
            currentExcel = excelFiles{i};
            try
                process_excel_dose_workbook_r2015(currentExcel, fileparts(currentExcel), ced, grau);
                processedExcel = processedExcel + 1;
                disp(['Processed dose workbook: ' currentExcel]);
            catch ME
                disp(['Failed to process dose workbook ', currentExcel, ': ' ME.message]);
            end
        end
        disp(['Processed dose workbooks: ' num2str(processedExcel)]);
    end
elseif ~isempty(excelPath)
    if isempty(outDir)
        outDir = fileparts(excelPath);
    end
    process_excel_dose_workbook_r2015(excelPath, outDir, ced, grau);
end

%% ---------------- PART B: 3D DOSE PROFILES AND PLANES ----------------
if isempty(dose3dPath) && isempty(dose3dRoot)
    modeChoice = menu('3D dose mode', 'One 3d-dose.dat file', 'Scan root folder recursively', 'Skip');
    if modeChoice == 1
        [f, p] = uigetfile({'3d-dose*.dat;*.dat', 'PENELOPE 3D dose files'}, 'Select 3d-dose.dat file');
        if isequal(f, 0)
            disp('No 3D dose file selected; skipping 3D dose plots.');
        else
            dose3dPath = fullfile(p, f);
        end
    elseif modeChoice == 2
        rootChosen = uigetdir(pwd, 'Select root folder to scan recursively for 3d-dose files');
        if isequal(rootChosen, 0)
            disp('No root folder selected; skipping recursive 3D dose plots.');
        else
            dose3dRoot = rootChosen;
        end
    else
        disp('Skipping 3D dose plots.');
    end
end

if ~isempty(dose3dRoot)
    doseFiles = collect_3d_dose_files_r2015(dose3dRoot);
    if isempty(doseFiles)
        disp(['No 3d-dose files found under: ' dose3dRoot]);
    else
        processed = 0;
        for i = 1:numel(doseFiles)
            try
                process_single_3d_dose_r2015(doseFiles{i}, fileparts(doseFiles{i}), xT, yT, zT, selectedLabelSpecs, '');
                processed = processed + 1;
                disp(['Processed 3d-dose file: ' doseFiles{i}]);
            catch ME
                disp(['Failed to process ' doseFiles{i} ': ' ME.message]);
            end
        end
        disp(['Processed 3d-dose files: ' num2str(processed)]);
    end
elseif ~isempty(dose3dPath)
    if isempty(outDir)
        outDir = fileparts(dose3dPath);
    end
    process_single_3d_dose_r2015(dose3dPath, outDir, xT, yT, zT, selectedLabelSpecs, '');
end

end

function process_excel_dose_workbook_r2015(excelPath, outDir, ced, grau)
doseData = load_dose_sheet_r2015(excelPath);
n = numel(doseData.case_names);
THETA = nan(n, 1);
PHI = nan(n, 1);
ALPHA = nan(n, 1);
CASEID = nan(n, 1);

for i = 1:n
    c = doseData.case_names{i};
    tok = regexp(c, 'SCONE-([\-0-9\.]+)_([\-0-9\.]+)_([\-0-9\.]+)', 'tokens', 'once');
    if ~isempty(tok)
        THETA(i) = str2double(tok{1});
        PHI(i) = str2double(tok{2});
        ALPHA(i) = str2double(tok{3});
    end
    tok2 = regexp(c, 'case(\d+)', 'tokens', 'once');
    if ~isempty(tok2)
        CASEID(i) = str2double(tok2{1});
    end
end

validMask = ~isnan(ALPHA);
caseNames = doseData.case_names(validMask);
componentNames = doseData.component_names(validMask);
edepEv = doseData.edep_ev(validMask);
dEdepEv = doseData.dedep_ev(validMask);
doseEvg = doseData.dose_evg(validMask);
dDoseEvg = doseData.ddose_evg(validMask);
doseGy = doseData.dose_gy(validMask);
dDoseGy = doseData.ddose_gy(validMask);
THETA = THETA(validMask);
PHI = PHI(validMask);
ALPHA = ALPHA(validMask);
CASEID = CASEID(validMask);

alphas = unique(ALPHA);

totalAlpha = [];
totalComponent = {};
totalNFields = [];
totalEdepEv = [];
totaldEdepEv = [];
totalDoseEvg = [];
totaldDoseEvg = [];
totalErrPct = [];
totalDoseGy = [];
totaldDoseGy = [];

row = 0;
for a = 1:numel(alphas)
    alphaMask = (ALPHA == alphas(a));
    comps = unique(componentNames(alphaMask));
    for c = 1:numel(comps)
        compMask = alphaMask & strcmp(componentNames, comps{c});
        row = row + 1;
        totalAlpha(row, 1) = alphas(a); %#ok<AGROW>
        totalComponent{row, 1} = comps{c}; %#ok<AGROW>
        totalNFields(row, 1) = sum(compMask); %#ok<AGROW>
        totalEdepEv(row, 1) = sum(edepEv(compMask)); %#ok<AGROW>
        totaldEdepEv(row, 1) = sqrt(sum(dEdepEv(compMask).^2)); %#ok<AGROW>
        totalDoseEvg(row, 1) = sum(doseEvg(compMask)); %#ok<AGROW>
        totaldDoseEvg(row, 1) = sqrt(sum(dDoseEvg(compMask).^2)); %#ok<AGROW>
        if totalDoseEvg(row, 1) ~= 0
            totalErrPct(row, 1) = 100 * totaldDoseEvg(row, 1) / totalDoseEvg(row, 1); %#ok<AGROW>
        else
            totalErrPct(row, 1) = NaN; %#ok<AGROW>
        end
        totalDoseGy(row, 1) = sum(doseGy(compMask)); %#ok<AGROW>
        totaldDoseGy(row, 1) = sqrt(sum(dDoseGy(compMask).^2)); %#ok<AGROW>
    end
end

Totals = table( ...
    totalAlpha, totalComponent, totalNFields, totalEdepEv, totaldEdepEv, ...
    totalDoseEvg, totaldDoseEvg, totalErrPct, totalDoseGy, totaldDoseGy, ...
    'VariableNames', { ...
        'Alpha', 'Component', 'NFields', 'Edep_eV', 'dEdep_eV', ...
        'Dose_eVg', 'dDose_eVg', 'Error_pct', 'Dose_Gy', 'dDose_Gy' ...
    });
writetable(Totals, fullfile(outDir, 'body_totals_by_alpha.csv'));

keyNames = {'tumor olho dto'; 'Olho direito'; 'Olho esquerdo'};
K = Totals(ismember(Totals.Component, keyNames), :);
writetable(K, fullfile(outDir, 'key_bodies_by_alpha.csv'));

fig = figure('Color', 'w');
hold on;
legendLabels = {};
for a = 1:numel(alphas)
    Ka = K(K.Alpha == alphas(a), :);
    orderedIdx = zeros(numel(keyNames), 1);
    for j = 1:numel(keyNames)
        matchIdx = find(strcmp(Ka.Component, keyNames{j}), 1, 'first');
        if ~isempty(matchIdx)
            orderedIdx(j) = matchIdx;
        end
    end
    orderedIdx = orderedIdx(orderedIdx > 0);
    if isempty(orderedIdx)
        continue;
    end
    Ka = Ka(orderedIdx, :);
    errorbar(1:height(Ka), Ka.Dose_eVg, Ka.dDose_eVg, 'o-');
    legendLabels{end + 1} = sprintf('alpha = %.4g%c', alphas(a), grau); %#ok<AGROW>
end
set(gca, 'YScale', 'log', 'XTick', 1:3, 'XTickLabel', keyNames);
ylabel('Dose total (eV/g)');
title('Dose total: tumor e olhos');
grid on;
if ~isempty(legendLabels)
    legend(legendLabels, 'Location', 'best');
end
saveas(fig, fullfile(outDir, 'bar_key_bodies_by_alpha.png'));
close(fig);

cases = unique(caseNames);
rankCase = {};
rankCaseID = [];
rankAlpha = [];
rankTheta = [];
rankPhi = [];
rankTumorDose = [];
rankRightEyeDose = [];
rankLeftEyeDose = [];
rankBothPct = [];
rankMaxPct = [];
r = 0;

for i = 1:numel(cases)
    caseMask = strcmp(caseNames, cases{i});
    tumorMask = caseMask & strcmp(componentNames, 'tumor olho dto');
    odMask = caseMask & strcmp(componentNames, 'Olho direito');
    oeMask = caseMask & strcmp(componentNames, 'Olho esquerdo');
    tumorIdx = find(tumorMask, 1, 'first');
    odIdx = find(odMask, 1, 'first');
    oeIdx = find(oeMask, 1, 'first');
    if ~isempty(tumorIdx) && ~isempty(odIdx) && ~isempty(oeIdx)
        r = r + 1;
        rankCase{r, 1} = cases{i}; %#ok<AGROW>
        rankCaseID(r, 1) = CASEID(tumorIdx); %#ok<AGROW>
        rankAlpha(r, 1) = ALPHA(tumorIdx); %#ok<AGROW>
        rankTheta(r, 1) = THETA(tumorIdx); %#ok<AGROW>
        rankPhi(r, 1) = PHI(tumorIdx); %#ok<AGROW>
        rankTumorDose(r, 1) = doseEvg(tumorIdx); %#ok<AGROW>
        rankRightEyeDose(r, 1) = doseEvg(odIdx); %#ok<AGROW>
        rankLeftEyeDose(r, 1) = doseEvg(oeIdx); %#ok<AGROW>
        rankBothPct(r, 1) = 100 * (rankRightEyeDose(r, 1) + rankLeftEyeDose(r, 1)) / rankTumorDose(r, 1); %#ok<AGROW>
        rankMaxPct(r, 1) = 100 * max(rankRightEyeDose(r, 1), rankLeftEyeDose(r, 1)) / rankTumorDose(r, 1); %#ok<AGROW>
    end
end

R = table( ...
    rankCase, rankCaseID, rankAlpha, rankTheta, rankPhi, ...
    rankTumorDose, rankRightEyeDose, rankLeftEyeDose, rankBothPct, rankMaxPct, ...
    'VariableNames', { ...
        'Case', 'CaseID', 'Alpha', 'THETA', 'PHI', ...
        'TumorDose_eVg', 'RightEyeDose_eVg', 'LeftEyeDose_eVg', ...
        'BothEyes_Tumor_pct', 'MaxEye_Tumor_pct' ...
    });
if ~isempty(R)
    R = sortrows(R, {'Alpha', 'BothEyes_Tumor_pct'});
end
writetable(R, fullfile(outDir, 'angle_ranking_by_alpha.csv'));

for a = 1:numel(alphas)
    Ra = R(R.Alpha == alphas(a), :);
    if isempty(Ra)
        continue;
    end
    labels = cell(height(Ra), 1);
    for j = 1:height(Ra)
        labels{j} = sprintf('T%.0f_P%.0f', Ra.THETA(j), Ra.PHI(j));
    end
    fig = figure('Color', 'w');
    bar(Ra.BothEyes_Tumor_pct);
    set(gca, 'XTick', 1:height(Ra), 'XTickLabel', labels);
    try
        set(gca, 'XTickLabelRotation', 60);
    catch
    end
    ylabel('(Dose OD + OE)/Dose no tumor (%)');
    title(sprintf(['Ordena' ced 'o angular, alfa = %.4g%c'], alphas(a), grau));
    grid on;
    saveas(fig, fullfile(outDir, ['angle_ranking_alpha_', strrep(num2str(alphas(a)), '.', 'p'), '.png']));
    close(fig);
end
end

function files = collect_dose_workbooks_r2015(rootDir)
paths = regexp(genpath(rootDir), pathsep, 'split');
files = {};
for i = 1:numel(paths)
    currentDir = paths{i};
    if isempty(currentDir)
        continue;
    end
    lowerDir = lower(currentDir);
    if ~isempty(strfind(lowerDir, [filesep 'previous_runs'])) || ...
       ~isempty(strfind(lowerDir, [filesep 'dmps'])) || ...
       ~isempty(strfind(lowerDir, [filesep '3d-dose_group'])) || ...
       ~isempty(strfind(lowerDir, [filesep 'old appends']))
        continue;
    end
    matches = [dir(fullfile(currentDir, '*.xlsx')); dir(fullfile(currentDir, '*.xls'))];
    for j = 1:numel(matches)
        if matches(j).isdir
            continue;
        end
        candidate = fullfile(currentDir, matches(j).name);
        try
            if is_penelope_dose_workbook_r2015(candidate)
                files{end + 1, 1} = candidate; %#ok<AGROW>
            end
        catch
        end
    end
end
if ~isempty(files)
    files = sort(files);
end
end

function ok = is_penelope_dose_workbook_r2015(path)
ok = false;
try
    [~, ~, raw] = xlsread(path, 'Dose');
catch
    return;
end
if isempty(raw) || size(raw, 1) < 1
    return;
end
headers = raw(1, :);
required = { ...
    {'Case'}, ...
    {'Component'}, ...
    {'Edep (eV)', 'Edep_eV'}, ...
    {'dE (eV)', 'dE_eV'}, ...
    {'Dose (eV/g)', 'Dose_eV_g'}, ...
    {'dDose (eV/g)', 'dDose_eV_g'}, ...
    {'Dose (Gy)', 'Dose_Gy'}, ...
    {'dDose (Gy)', 'dDose_Gy'} ...
};
for i = 1:numel(required)
    if isnan(find_header_index(headers, required{i}))
        return;
    end
end
ok = true;
end

function data = load_dose_sheet_r2015(excelPath)
[~, ~, raw] = xlsread(excelPath, 'Dose');
if isempty(raw) || size(raw, 1) < 2
    error('Dose sheet is empty or missing usable rows.');
end

headers = raw(1, :);
rows = raw(2:end, :);

caseIdx = find_header_index(headers, {'Case'});
componentIdx = find_header_index(headers, {'Component'});
edepIdx = find_header_index(headers, {'Edep (eV)', 'Edep_eV'});
dedepIdx = find_header_index(headers, {'dE (eV)', 'dE_eV'});
doseEvgIdx = find_header_index(headers, {'Dose (eV/g)', 'Dose_eV_g'});
ddoseEvgIdx = find_header_index(headers, {'dDose (eV/g)', 'dDose_eV_g'});
doseGyIdx = find_header_index(headers, {'Dose (Gy)', 'Dose_Gy'});
ddoseGyIdx = find_header_index(headers, {'dDose (Gy)', 'dDose_Gy'});

data.case_names = cell_column_to_strings(rows(:, caseIdx));
data.component_names = cell_column_to_strings(rows(:, componentIdx));
data.edep_ev = cell_column_to_numeric(rows(:, edepIdx));
data.dedep_ev = cell_column_to_numeric(rows(:, dedepIdx));
data.dose_evg = cell_column_to_numeric(rows(:, doseEvgIdx));
data.ddose_evg = cell_column_to_numeric(rows(:, ddoseEvgIdx));
data.dose_gy = cell_column_to_numeric(rows(:, doseGyIdx));
data.ddose_gy = cell_column_to_numeric(rows(:, ddoseGyIdx));

keep = ~cellfun(@isempty, data.case_names) & ~cellfun(@isempty, data.component_names);
data.case_names = data.case_names(keep);
data.component_names = data.component_names(keep);
data.edep_ev = data.edep_ev(keep);
data.dedep_ev = data.dedep_ev(keep);
data.dose_evg = data.dose_evg(keep);
data.ddose_evg = data.ddose_evg(keep);
data.dose_gy = data.dose_gy(keep);
data.ddose_gy = data.ddose_gy(keep);
end

function idx = find_header_index(headers, candidates)
idx = [];
for i = 1:numel(headers)
    current = normalize_header_name(headers{i});
    for j = 1:numel(candidates)
        if strcmp(current, normalize_header_name(candidates{j}))
            idx = i;
            return;
        end
    end
end
error('Could not find expected Excel column header.');
end

function out = normalize_header_name(value)
if isnumeric(value)
    value = num2str(value);
elseif ~ischar(value)
    value = '';
end
out = lower(regexprep(strtrim(value), '[^a-z0-9]+', ''));
end

function values = cell_column_to_strings(col)
values = cell(size(col));
for i = 1:numel(col)
    item = col{i};
    if ischar(item)
        values{i} = strtrim(item);
    elseif isnumeric(item)
        if isempty(item) || isnan(item)
            values{i} = '';
        else
            values{i} = strtrim(num2str(item));
        end
    else
        values{i} = '';
    end
end
values = values(:);
end

function values = cell_column_to_numeric(col)
values = nan(numel(col), 1);
for i = 1:numel(col)
    item = col{i};
    if isnumeric(item)
        if ~isempty(item)
            values(i) = item(1);
        end
    elseif ischar(item)
        temp = str2double(strrep(strrep(strtrim(item), 'D', 'E'), 'd', 'e'));
        if ~isnan(temp)
            values(i) = temp;
        end
    end
end
end

function S = load_3d_dose_r2015(path)
fid = fopen(path, 'rt');
if fid < 0
    error('Could not open 3d-dose file.');
end
cleanup = onCleanup(@() fclose(fid));
cols = textscan(fid, '%f%f%f%f%f%f%f%f', 'CommentStyle', '#', ...
    'CollectOutput', true, 'MultipleDelimsAsOne', true, 'Delimiter', {' ', '\t'});
S = cols{1};
if isempty(S) || size(S, 2) < 8
    error('No valid numeric 3D dose rows were found.');
end
end

function process_single_3d_dose_r2015(dose3dPath, outDir, xT, yT, zT, labelSpecs, prefix)
if nargin < 9
    prefix = '';
end

[~, stem, ~] = fileparts(dose3dPath);
S = load_3d_dose_r2015(dose3dPath);
x = S(:, 1);
y = S(:, 2);
z = S(:, 3);
dose = S(:, 4);
u3sig = S(:, 5);
ix = round(S(:, 6));
iy = round(S(:, 7));
iz = round(S(:, 8));
nx = max(ix);
ny = max(iy);
nz = max(iz);

D = nan(nx, ny, nz);
U = nan(nx, ny, nz);
lin = sub2ind([nx, ny, nz], ix, iy, iz);
D(lin) = dose;
U(lin) = u3sig;

xVec = accumarray(ix, x, [nx 1], @mean);
yVec = accumarray(iy, y, [ny 1], @mean);
zVec = accumarray(iz, z, [nz 1], @mean);

[~, ixt] = min(abs(xVec - xT));
[~, iyt] = min(abs(yVec - yT));
[~, izt] = min(abs(zVec - zT));

filePrefix = prefix;
if isempty(filePrefix)
    if ~strcmpi(stem, '3d-dose')
        filePrefix = [stem '_'];
    end
end

plot_plane_r2015( ...
    xVec, yVec, squeeze(D(:, :, izt))', labelSpecs, 'xy', ...
    'x (cm)', 'y (cm)', sprintf('Plano XY, z = %.2f cm', zVec(izt)), ...
    fullfile(outDir, [filePrefix 'plane_XY_tumor.png']));
plot_plane_r2015( ...
    xVec, zVec, squeeze(D(:, iyt, :))', labelSpecs, 'xz', ...
    'x (cm)', 'z (cm)', sprintf('Plano XZ, y = %.2f cm', yVec(iyt)), ...
    fullfile(outDir, [filePrefix 'plane_XZ_tumor.png']));
plot_plane_r2015( ...
    yVec, zVec, squeeze(D(ixt, :, :))', labelSpecs, 'yz', ...
    'y (cm)', 'z (cm)', sprintf('Plano YZ, x = %.2f cm', xVec(ixt)), ...
    fullfile(outDir, [filePrefix 'plane_YZ_tumor.png']));

relU = 100 * squeeze(U(:, :, izt))' ./ squeeze(D(:, :, izt))';
relU(~isfinite(relU) | squeeze(D(:, :, izt))' <= 1e-30) = NaN;
fig = figure('Color', 'w');
imagesc(xVec, yVec, relU);
axis xy equal tight;
colorbar;
xlabel('x (cm)');
ylabel('y (cm)');
title('Incerteza relativa 3sigma (%) no plano XY');
saveas(fig, fullfile(outDir, [filePrefix 'uncertainty_XY_3sigma_pct.png']));
close(fig);

plotStem = stem;
d = 0.5;
tol_xy = 0.5;
tol_xz = 0.3;
tol_yz = 0.3;
dose1 = dose;
doseT = dose;
raw_ix = find((abs(y - yT) <= d) .* (abs(z - zT) <= d));
raw_iy = find((abs(x - xT) <= d) .* (abs(z - zT) <= d));
raw_iz = find((abs(x - xT) <= d) .* (abs(y - yT) <= d));
raw_i_xy = find((abs(z - zT) < tol_xy) .* (doseT > 1e-10));
raw_i_xz = find((abs(y - yT) < tol_xz) .* (doseT > 1e-10));
raw_i_yz = find((abs(x - xT) < tol_yz) .* (doseT > 1e-10));

fig = figure('Color', 'w');
plot(x(raw_ix), dose1(raw_ix), '.');
hold on;
plot(x(raw_ix), doseT(raw_ix), 'k*');
xlabel('x (cm)');
ylabel('Dose (eV/g)');
title('Perfil de dose ao longo de X');
legend('dose 1', 'total');
grid on;
hold off;
saveas(fig, fullfile(outDir, [plotStem '_profile_x.png']));
close(fig);

fig = figure('Color', 'w');
plot(y(raw_iy), dose1(raw_iy), '.');
hold on;
plot(y(raw_iy), doseT(raw_iy), 'k*');
xlabel('y (cm)');
ylabel('Dose (eV/g)');
title('Perfil de dose ao longo de Y');
legend('dose 1', 'total');
grid on;
hold off;
saveas(fig, fullfile(outDir, [plotStem '_profile_y.png']));
close(fig);

fig = figure('Color', 'w');
plot(z(raw_iz), dose1(raw_iz), '.');
hold on;
plot(z(raw_iz), doseT(raw_iz), 'k*');
xlabel('z (cm)');
ylabel('Dose (eV/g)');
title('Perfil de dose ao longo de Z');
legend('dose 1', 'total');
grid on;
hold off;
saveas(fig, fullfile(outDir, [plotStem '_profile_z.png']));
close(fig);

fig = figure('Color', 'w');
scatter(x(raw_i_xy), y(raw_i_xy), 20, doseT(raw_i_xy), 'filled');
hold on;
[markerHandles, markerNames] = plot_selected_geometry_labels_r2015(labelSpecs, 'xy');
colorbar;
xlabel('x (cm)');
ylabel('y (cm)');
title(['Distribui' ced 'o de dose no plano XY (z = ', num2str(zT), ' cm)']);
axis equal;
grid on;
if ~isempty(markerHandles)
    legend(markerHandles, markerNames, 'Location', 'northeastoutside');
end
hold off;
saveas(fig, fullfile(outDir, [plotStem '_xy.png']));
close(fig);

fig = figure('Color', 'w');
scatter(x(raw_i_xz), z(raw_i_xz), 20, doseT(raw_i_xz), 'filled');
hold on;
[markerHandles, markerNames] = plot_selected_geometry_labels_r2015(labelSpecs, 'xz');
colorbar;
xlabel('x (cm)');
ylabel('z (cm)');
title(['Distribui' ced 'o de dose no plano XZ (y = ', num2str(yT), ' cm)']);
axis equal;
grid on;
if ~isempty(markerHandles)
    legend(markerHandles, markerNames, 'Location', 'northeastoutside');
end
hold off;
saveas(fig, fullfile(outDir, [plotStem '_xz.png']));
close(fig);

fig = figure('Color', 'w');
scatter(y(raw_i_yz), z(raw_i_yz), 20, doseT(raw_i_yz), 'filled');
hold on;
[markerHandles, markerNames] = plot_selected_geometry_labels_r2015(labelSpecs, 'yz');
colorbar;
xlabel('y (cm)');
ylabel('z (cm)');
title(['Distribui' ced 'o de dose no plano YZ (x = ', num2str(xT), ' cm)']);
axis equal;
grid on;
if ~isempty(markerHandles)
    legend(markerHandles, markerNames, 'Location', 'northeastoutside');
end
hold off;
saveas(fig, fullfile(outDir, [plotStem '_yz.png']));
close(fig);
end

function files = collect_3d_dose_files_r2015(rootDir)
paths = regexp(genpath(rootDir), pathsep, 'split');
files = {};
for i = 1:numel(paths)
    currentDir = paths{i};
    if isempty(currentDir)
        continue;
    end
    lowerDir = lower(currentDir);
    if ~isempty(strfind(lowerDir, [filesep 'previous_runs'])) || ...
       ~isempty(strfind(lowerDir, [filesep 'dmps'])) || ...
       ~isempty(strfind(lowerDir, [filesep '3d-dose_group'])) || ...
       ~isempty(strfind(lowerDir, '_3d_dose_header_backup_'))
        continue;
    end
    matches = dir(fullfile(currentDir, '3d-dose*.dat'));
    for j = 1:numel(matches)
        if ~matches(j).isdir
            files{end + 1, 1} = fullfile(currentDir, matches(j).name); %#ok<AGROW>
        end
    end
end
end

function plot_plane_r2015(aVec, bVec, M, labelSpecs, planeMode, xlab, ylab, ttl, outPath)
fig = figure('Color', 'w');
imagesc(aVec, bVec, M);
axis xy equal tight;
colorbar;
hold on;
[markerHandles, markerNames] = plot_selected_geometry_labels_r2015(labelSpecs, planeMode);
xlabel(xlab);
ylabel(ylab);
title(ttl);
grid on;
if ~isempty(markerHandles)
    legend(markerHandles, markerNames, 'Location', 'northeastoutside');
end
saveas(fig, outPath);
close(fig);
end

function [handles, names] = plot_selected_geometry_labels_r2015(labelSpecs, planeMode)
handles = [];
names = {};
if isempty(labelSpecs)
    return;
end
for idx = 1:size(labelSpecs, 1)
    row = labelSpecs(idx, :);
    if numel(row) < 5
        continue;
    end
    label = row{1};
    marker = row{2};
    xVal = row{3};
    yVal = row{4};
    zVal = row{5};
    [aVal, bVal] = project_geometry_label_r2015(xVal, yVal, zVal, planeMode);
    if ~isfinite(aVal) || ~isfinite(bVal)
        continue;
    end
    if strcmp(marker, 'o')
        h = plot(aVal, bVal, 'ko', 'MarkerSize', 8, 'LineWidth', 1.5);
    else
        h = plot(aVal, bVal, 'kx', 'MarkerSize', 9, 'LineWidth', 1.5);
    end
    handles = [handles h]; %#ok<AGROW>
    names{end + 1, 1} = label; %#ok<AGROW>
end
end

function [aVal, bVal] = project_geometry_label_r2015(xVal, yVal, zVal, planeMode)
aVal = NaN;
bVal = NaN;
mode = lower(strtrim(planeMode));
if strcmp(mode, 'xy')
    aVal = xVal;
    bVal = yVal;
elseif strcmp(mode, 'xz')
    aVal = xVal;
    bVal = zVal;
elseif strcmp(mode, 'yz')
    aVal = yVal;
    bVal = zVal;
end
end
