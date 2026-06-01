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
    {'Tumor olho dto', 'target', xTumorOlhoDto, yTumorOlhoDto, zTumorOlhoDto};
    {'Olho direito', 'body', xOlhoDireito, yOlhoDireito, zOlhoDireito};
    {'Olho esquerdo', 'body', xOlhoEsquerdo, yOlhoEsquerdo, zOlhoEsquerdo}
};
selectedBodyNames = {
    'Tumor olho dto';
    'Olho direito';
    'Olho esquerdo'
};
targetBodyName = 'Tumor olho dto';
comparisonBodyNames = {
    'Olho direito';
    'Olho esquerdo'
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
scriptRoot = fileparts(mfilename('fullpath'));

batchRootsAuto = collect_batch_analysis_roots_r2015(scriptRoot);
if isempty(excelPath) && isempty(excelRoot) && isempty(dose3dPath) && isempty(dose3dRoot) && ~isempty(batchRootsAuto)
    rootWorkbooks = collect_dose_workbooks_here_r2015(scriptRoot);
    useRootWorkbooks = false;
    if ~isempty(rootWorkbooks)
        rootChoice = menu('Dose workbooks in selected root', 'Use root workbook(s) too', 'Ignore root workbook(s)');
        useRootWorkbooks = (rootChoice == 1);
    end
    batchWorkbookChoice = menu('Batch workbook step', 'Process batch workbook(s)', 'Skip batch workbook(s)');
    batchCaseDoseChoice = menu('Batch case 3D-dose step', 'Process individual case 3D-dose files', 'Skip individual case 3D-dose files');
    batchGroupDoseChoice = menu('Batch 3D-dose group step', 'Process grouped 3D-dose folders', 'Skip grouped 3D-dose folders');
    doBatchWorkbooks = (batchWorkbookChoice == 1);
    doBatchCaseDoses = (batchCaseDoseChoice == 1);
    doBatchGroupDoses = (batchGroupDoseChoice == 1);
    if useRootWorkbooks
        for i = 1:numel(rootWorkbooks)
            try
                process_excel_dose_workbook_r2015(rootWorkbooks{i}, fileparts(rootWorkbooks{i}), ced, grau, targetBodyName, comparisonBodyNames);
                disp(['Processed root dose workbook: ' rootWorkbooks{i}]);
            catch ME
                disp(['Failed to process root dose workbook ', rootWorkbooks{i}, ': ' ME.message]);
            end
        end
    end
    processedBatches = 0;
    for i = 1:numel(batchRootsAuto)
        try
            process_batch_analysis_root_r2015(batchRootsAuto{i}, xT, yT, zT, selectedLabelSpecs, targetBodyName, comparisonBodyNames, ced, grau, doBatchWorkbooks, doBatchCaseDoses, doBatchGroupDoses);
            processedBatches = processedBatches + 1;
        catch ME
            disp(['Failed to process batch root ', batchRootsAuto{i}, ': ' ME.message]);
        end
    end
    disp(['Processed batch folders: ' num2str(processedBatches)]);
    return;
end

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
                process_excel_dose_workbook_r2015(currentExcel, fileparts(currentExcel), ced, grau, targetBodyName, comparisonBodyNames);
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
    process_excel_dose_workbook_r2015(excelPath, outDir, ced, grau, targetBodyName, comparisonBodyNames);
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
        doseFiles = choose_path_subset_r2015(doseFiles, '3D-dose files found under root', dose3dRoot);
        if isempty(doseFiles)
            disp('No 3D-dose files selected; skipping recursive 3D dose plots.');
            return;
        end
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

function process_excel_dose_workbook_r2015(excelPath, outDir, ced, grau, targetBodyName, comparisonBodyNames)
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
sourceTypes = doseData.source_types(validMask);
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
sourceTypes = fill_empty_labels_r2015(sourceTypes, 'Unknown source');

alphas = unique(ALPHA);

totalSourceType = {};
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
    sourceList = unique(sourceTypes(alphaMask));
    for s = 1:numel(sourceList)
        sourceMask = alphaMask & strcmp(sourceTypes, sourceList{s});
        comps = unique(componentNames(sourceMask));
        for c = 1:numel(comps)
            compMask = sourceMask & strcmp(componentNames, comps{c});
            row = row + 1;
            totalSourceType{row, 1} = sourceList{s}; %#ok<AGROW>
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
end

Totals = table( ...
    totalSourceType, totalAlpha, totalComponent, totalNFields, totalEdepEv, totaldEdepEv, ...
    totalDoseEvg, totaldDoseEvg, totalErrPct, totalDoseGy, totaldDoseGy, ...
    'VariableNames', { ...
        'SourceType', 'Alpha', 'Component', 'NFields', 'Edep_eV', 'dEdep_eV', ...
        'Dose_eVg', 'dDose_eVg', 'Error_pct', 'Dose_Gy', 'dDose_Gy' ...
    });
writetable(Totals, fullfile(outDir, 'body_totals_by_alpha.csv'));

keyNames = normalize_body_name_list_r2015({});
if exist('selectedBodyNames', 'var')
    keyNames = normalize_body_name_list_r2015(selectedBodyNames);
end
if isempty(keyNames)
    keyNames = resolve_selected_body_names_r2015(selectedLabelSpecs);
end
if isempty(keyNames)
    keyNames = {'tumor olho dto'; 'Olho direito'; 'Olho esquerdo'};
end
K = Totals(build_component_match_mask_r2015(Totals.Component, keyNames), :);
writetable(K, fullfile(outDir, 'key_bodies_by_alpha.csv'));

plotSources = unique(K.SourceType);
multiSourceBodies = numel(plotSources) > 1;
for s = 1:numel(plotSources)
    Ks = K(strcmp(K.SourceType, plotSources{s}), :);
    if isempty(Ks)
        continue;
    end
    fig = figure('Color', 'w');
    hold on;
    legendLabels = {};
    alphaList = unique(Ks.Alpha);
    for a = 1:numel(alphaList)
        Ka = Ks(Ks.Alpha == alphaList(a), :);
        orderedIdx = zeros(numel(keyNames), 1);
        for j = 1:numel(keyNames)
            matchIdx = find_component_row_r2015(Ka.Component, keyNames{j});
            if ~isempty(matchIdx)
                orderedIdx(j) = matchIdx;
            end
        end
        xVals = find(orderedIdx > 0);
        if isempty(xVals)
            continue;
        end
        Ka = Ka(orderedIdx(xVals), :);
        errorbar(xVals, Ka.Dose_eVg, Ka.dDose_eVg, 'o-');
        legendLabels{end + 1} = sprintf('alpha = %.4g%c', alphaList(a), grau); %#ok<AGROW>
    end
    set(gca, 'YScale', 'log', 'XTick', 1:numel(keyNames), 'XTickLabel', keyNames);
    xlim([0.5, numel(keyNames) + 0.5]);
    ylabel('Dose total somada (eV/g)');
    title(sprintf('Dose total somada por corpo selecionado: %s', display_source_type_r2015(plotSources{s})));
    grid on;
    if ~isempty(legendLabels)
        legend(legendLabels, 'Location', 'best');
    end
    if multiSourceBodies
        outName = ['bar_key_bodies_by_alpha_', safe_file_token_r2015(plotSources{s}), '.png'];
    else
        outName = 'bar_key_bodies_by_alpha.png';
    end
    saveas(fig, fullfile(outDir, outName));
    close(fig);
end

cases = unique(caseNames);
targetNames = normalize_body_name_list_r2015(targetBodyName);
if isempty(targetNames)
    targetNames = resolve_target_body_name_r2015(selectedLabelSpecs);
end
if isempty(targetNames)
    targetNames = {'tumor olho dto'};
end
targetName = targetNames{1};

compareNames = normalize_body_name_list_r2015(comparisonBodyNames);
if isempty(compareNames)
    compareNames = resolve_default_comparison_body_names_r2015(selectedBodyNames, targetName);
end

for cmpIdx = 1:numel(compareNames)
    compareName = compareNames{cmpIdx};
    rankCase = {};
    rankSourceType = {};
    rankCaseID = [];
    rankAlpha = [];
    rankTheta = [];
    rankPhi = [];
    rankTargetDose = [];
    rankCompareDose = [];
    rankComparePct = [];
    r = 0;

    for i = 1:numel(cases)
        caseMask = strcmp(caseNames, cases{i});
        targetIdx = find(caseMask & build_component_match_mask_r2015(componentNames, {targetName}), 1, 'first');
        compareIdx = find(caseMask & build_component_match_mask_r2015(componentNames, {compareName}), 1, 'first');
        if ~isempty(targetIdx) && ~isempty(compareIdx)
            r = r + 1;
            rankCase{r, 1} = cases{i}; %#ok<AGROW>
            rankSourceType{r, 1} = sourceTypes{targetIdx}; %#ok<AGROW>
            rankCaseID(r, 1) = CASEID(targetIdx); %#ok<AGROW>
            rankAlpha(r, 1) = ALPHA(targetIdx); %#ok<AGROW>
            rankTheta(r, 1) = THETA(targetIdx); %#ok<AGROW>
            rankPhi(r, 1) = PHI(targetIdx); %#ok<AGROW>
            rankTargetDose(r, 1) = doseEvg(targetIdx); %#ok<AGROW>
            rankCompareDose(r, 1) = doseEvg(compareIdx); %#ok<AGROW>
            rankComparePct(r, 1) = 100 * rankCompareDose(r, 1) / rankTargetDose(r, 1); %#ok<AGROW>
        end
    end

    R = table( ...
        rankCase, rankSourceType, rankCaseID, rankAlpha, rankTheta, rankPhi, ...
        rankTargetDose, rankCompareDose, rankComparePct, ...
        'VariableNames', { ...
            'Case', 'SourceType', 'CaseID', 'Alpha', 'THETA', 'PHI', ...
            'TargetDose_eVg', 'CompareDose_eVg', 'CompareTarget_pct' ...
        });
    if ~isempty(R)
        R = sortrows(R, {'Alpha', 'SourceType', 'CompareTarget_pct'});
    end
    compareToken = safe_file_token_r2015(compareName);
    targetToken = safe_file_token_r2015(targetName);
    writetable(R, fullfile(outDir, ['angle_ranking_' compareToken '_vs_' targetToken '.csv']));

    alphaRankList = unique(R.Alpha);
    for a = 1:numel(alphaRankList)
        sourceList = unique(R.SourceType(R.Alpha == alphaRankList(a)));
        for s = 1:numel(sourceList)
            Ra = R(R.Alpha == alphaRankList(a) & strcmp(R.SourceType, sourceList{s}), :);
            if isempty(Ra)
                continue;
            end
            labels = cell(height(Ra), 1);
            for j = 1:height(Ra)
                labels{j} = sprintf('T%.0f P%.0f', Ra.THETA(j), Ra.PHI(j));
            end
            tickIdx = 1:height(Ra);
            if height(Ra) > 16
                step = max(1, ceil(height(Ra) / 16));
                tickIdx = unique([1:step:height(Ra), height(Ra)]);
            end
            figWidth = max(960, 52 * height(Ra));
            fig = figure('Color', 'w', 'Position', [100, 100, figWidth, 520]);
            bar(Ra.CompareTarget_pct);
            set(gca, 'XTick', tickIdx, 'XTickLabel', labels(tickIdx));
            try
                set(gca, 'XTickLabelRotation', 45);
            catch
            end
            ylabel(sprintf('%s / %s (%%)', compareName, targetName));
            title(sprintf(['Ordena' ced 'o angular, alfa = %.4g%c, fonte = %s, compara' ced 'o = %s / %s'], alphaRankList(a), grau, display_source_type_r2015(sourceList{s}), compareName, targetName));
            grid on;
            outName = ['angle_ranking_' compareToken '_vs_' targetToken '_alpha_' strrep(num2str(alphaRankList(a)), '.', 'p') '_' safe_file_token_r2015(sourceList{s}) '.png'];
            saveas(fig, fullfile(outDir, outName));
            close(fig);
        end
    end
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

function files = collect_dose_workbooks_here_r2015(rootDir)
matches = [dir(fullfile(rootDir, '*.xlsx')); dir(fullfile(rootDir, '*.xls'))];
files = {};
for i = 1:numel(matches)
    if matches(i).isdir
        continue;
    end
    candidate = fullfile(rootDir, matches(i).name);
    try
        if is_penelope_dose_workbook_r2015(candidate)
            files{end + 1, 1} = candidate; %#ok<AGROW>
        end
    catch
    end
end
if ~isempty(files)
    files = sort(files);
end
end

function roots = collect_batch_analysis_roots_r2015(rootDir)
entries = dir(rootDir);
roots = {};
for i = 1:numel(entries)
    entry = entries(i);
    if ~entry.isdir
        continue;
    end
    name = strtrim(entry.name);
    if strcmp(name, '.') || strcmp(name, '..')
        continue;
    end
    lowerName = lower(name);
    if strcmp(lowerName, 'previous_runs') || strcmp(lowerName, 'dmps') || strcmp(lowerName, '3d-dose_group') || strcmp(lowerName, 'old appends')
        continue;
    end
    child = fullfile(rootDir, name);
    if ~isempty(collect_dose_workbooks_r2015(child)) || ...
       ~isempty(collect_3d_dose_files_r2015(child)) || ...
       ~isempty(collect_group_3d_dose_folders_r2015(child))
        roots{end + 1, 1} = child; %#ok<AGROW>
    end
end
if ~isempty(roots)
    roots = sort(roots);
end
end

function folders = collect_group_3d_dose_folders_r2015(rootDir)
paths = regexp(genpath(rootDir), pathsep, 'split');
folders = {};
for i = 1:numel(paths)
    currentDir = paths{i};
    if isempty(currentDir)
        continue;
    end
    lowerDir = lower(currentDir);
    [~, baseName] = fileparts(currentDir);
    if ~strcmpi(baseName, '3d-dose_group')
        continue;
    end
    if isempty(dir(fullfile(currentDir, '3d-dose*.dat')))
        continue;
    end
    if ~isempty(strfind(lowerDir, [filesep 'previous_runs'])) || ...
       ~isempty(strfind(lowerDir, [filesep 'dmps']))
        continue;
    end
    folders{end + 1, 1} = currentDir; %#ok<AGROW>
end
if ~isempty(folders)
    folders = sort(folders);
end
end

function process_batch_analysis_root_r2015(batchRoot, xT, yT, zT, labelSpecs, targetBodyName, comparisonBodyNames, ced, grau, doExcel, doSingle3d, doGroup3d)
disp(['Processing batch root: ' batchRoot]);
if nargin < 9 || isempty(doExcel)
    doExcel = true;
end
if nargin < 10 || isempty(doSingle3d)
    doSingle3d = true;
end
if nargin < 11 || isempty(doGroup3d)
    doGroup3d = true;
end

if doExcel
    excelFiles = collect_dose_workbooks_here_r2015(batchRoot);
    for i = 1:numel(excelFiles)
        try
            process_excel_dose_workbook_r2015(excelFiles{i}, fileparts(excelFiles{i}), ced, grau, targetBodyName, comparisonBodyNames);
            disp(['Processed batch workbook: ' excelFiles{i}]);
        catch ME
            disp(['Failed batch workbook ', excelFiles{i}, ': ' ME.message]);
        end
    end
end

if doSingle3d
    doseFiles = collect_3d_dose_files_r2015(batchRoot);
    doseFiles = choose_path_subset_r2015(doseFiles, ['3D-dose files in batch: ' short_name_r2015(batchRoot)], batchRoot);
    for i = 1:numel(doseFiles)
        try
            process_single_3d_dose_r2015(doseFiles{i}, fileparts(doseFiles{i}), xT, yT, zT, labelSpecs, '');
            disp(['Processed batch 3d-dose: ' doseFiles{i}]);
        catch ME
            disp(['Failed batch 3d-dose ', doseFiles{i}, ': ' ME.message]);
        end
    end
end

if doGroup3d
    groupFolders = collect_group_3d_dose_folders_r2015(batchRoot);
    groupFolders = choose_path_subset_r2015(groupFolders, ['3D-dose group folders in batch: ' short_name_r2015(batchRoot)], batchRoot);
    for i = 1:numel(groupFolders)
        try
            process_grouped_3d_dose_folder_r2015(groupFolders{i}, xT, yT, zT, labelSpecs, ced);
            disp(['Processed grouped 3d-dose folder: ' groupFolders{i}]);
        catch ME
            disp(['Failed grouped 3d-dose folder ', groupFolders{i}, ': ' ME.message]);
        end
    end
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
sourceTypeIdx = find_optional_header_index(headers, {'Spectrum Type', 'Source Type', 'SourceType'});
componentIdx = find_header_index(headers, {'Component'});
edepIdx = find_header_index(headers, {'Edep (eV)', 'Edep_eV'});
dedepIdx = find_header_index(headers, {'dE (eV)', 'dE_eV'});
doseEvgIdx = find_header_index(headers, {'Dose (eV/g)', 'Dose_eV_g'});
ddoseEvgIdx = find_header_index(headers, {'dDose (eV/g)', 'dDose_eV_g'});
doseGyIdx = find_header_index(headers, {'Dose (Gy)', 'Dose_Gy'});
ddoseGyIdx = find_header_index(headers, {'dDose (Gy)', 'dDose_Gy'});

data.case_names = cell_column_to_strings(rows(:, caseIdx));
if ~isnan(sourceTypeIdx)
    data.source_types = cell_column_to_strings(rows(:, sourceTypeIdx));
else
    data.source_types = repmat({''}, size(rows, 1), 1);
end
data.component_names = cell_column_to_strings(rows(:, componentIdx));
data.edep_ev = cell_column_to_numeric(rows(:, edepIdx));
data.dedep_ev = cell_column_to_numeric(rows(:, dedepIdx));
data.dose_evg = cell_column_to_numeric(rows(:, doseEvgIdx));
data.ddose_evg = cell_column_to_numeric(rows(:, ddoseEvgIdx));
data.dose_gy = cell_column_to_numeric(rows(:, doseGyIdx));
data.ddose_gy = cell_column_to_numeric(rows(:, ddoseGyIdx));

keep = ~cellfun(@isempty, data.case_names) & ~cellfun(@isempty, data.component_names);
data.case_names = data.case_names(keep);
data.source_types = data.source_types(keep);
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

function idx = find_optional_header_index(headers, candidates)
idx = NaN;
for i = 1:numel(headers)
    current = normalize_header_name(headers{i});
    for j = 1:numel(candidates)
        if strcmp(current, normalize_header_name(candidates{j}))
            idx = i;
            return;
        end
    end
end
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

function labels = fill_empty_labels_r2015(labels, fallbackLabel)
labels = labels(:);
for i = 1:numel(labels)
    current = '';
    if ischar(labels{i})
        current = strtrim(labels{i});
    end
    if isempty(current)
        labels{i} = fallbackLabel;
    end
end
end

function names = normalize_body_name_list_r2015(rawNames)
names = {};
if nargin < 1 || isempty(rawNames)
    return;
end
if ischar(rawNames)
    rawNames = {rawNames};
elseif ~iscell(rawNames)
    return;
end
for i = 1:numel(rawNames)
    item = rawNames{i};
    label = '';
    if ischar(item)
        label = strtrim(item);
    elseif iscell(item) && ~isempty(item) && ischar(item{1})
        label = strtrim(item{1});
    end
    if isempty(label)
        continue;
    end
    duplicate = false;
    for j = 1:numel(names)
        if strcmpi(names{j}, label)
            duplicate = true;
            break;
        end
    end
    if ~duplicate
        names{end + 1, 1} = label; %#ok<AGROW>
    end
end
end

function names = resolve_selected_body_names_r2015(labelSpecs)
names = {};
if nargin < 1 || isempty(labelSpecs) || ~iscell(labelSpecs)
    return;
end
for i = 1:size(labelSpecs, 1)
    row = labelSpecs(i, :);
    if numel(row) == 1 && iscell(row{1})
        row = row{1};
    end
    if isempty(row)
        continue;
    end
    label = row{1};
    if iscell(label) && ~isempty(label)
        label = label{1};
    end
    names = normalize_body_name_list_r2015([names; {label}]);
end
end

function names = resolve_target_body_name_r2015(labelSpecs)
names = {};
if nargin < 1 || isempty(labelSpecs) || ~iscell(labelSpecs)
    return;
end
for i = 1:size(labelSpecs, 1)
    row = labelSpecs(i, :);
    if numel(row) == 1 && iscell(row{1})
        row = row{1};
    end
    if numel(row) < 2
        continue;
    end
    label = row{1};
    marker = lower(strtrim(char(row{2})));
    if strcmp(marker, 'target') || strcmp(marker, 'o')
        names = normalize_body_name_list_r2015({label});
        return;
    end
end
end

function names = resolve_default_comparison_body_names_r2015(selectedNames, targetName)
names = normalize_body_name_list_r2015(selectedNames);
targetNorm = normalize_body_name_list_r2015({targetName});
if isempty(names)
    return;
end
filtered = {};
for i = 1:numel(names)
    if ~strcmpi(names{i}, targetNorm{1})
        filtered{end + 1, 1} = names{i}; %#ok<AGROW>
    end
end
names = filtered;
end

function mask = build_component_match_mask_r2015(componentNames, desiredNames)
mask = false(numel(componentNames), 1);
desiredNames = normalize_body_name_list_r2015(desiredNames);
if isempty(desiredNames)
    return;
end
for i = 1:numel(componentNames)
    current = '';
    if ischar(componentNames{i})
        current = strtrim(componentNames{i});
    end
    for j = 1:numel(desiredNames)
        if strcmpi(current, desiredNames{j})
            mask(i) = true;
            break;
        end
    end
end
end

function idx = find_component_row_r2015(componentNames, desiredName)
idx = [];
desiredName = strtrim(desiredName);
for i = 1:numel(componentNames)
    current = '';
    if ischar(componentNames{i})
        current = strtrim(componentNames{i});
    end
    if strcmpi(current, desiredName)
        idx = i;
        return;
    end
end
end

function out = display_source_type_r2015(label)
out = strtrim(char(label));
if isempty(out)
    out = 'Unknown source';
end
end

function token = safe_file_token_r2015(label)
token = lower(regexprep(display_source_type_r2015(label), '[^a-z0-9]+', '_'));
token = regexprep(token, '_+', '_');
token = regexprep(token, '^_|_$', '');
if isempty(token)
    token = 'unknown_source';
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

function process_grouped_3d_dose_folder_r2015(groupDir, xT, yT, zT, labelSpecs, ced)
files = dir(fullfile(groupDir, '3d-dose_case*.dat'));
if isempty(files)
    files = dir(fullfile(groupDir, '3d-dose*.dat'));
end
if isempty(files)
    return;
end
[~, order] = sort({files.name});
files = files(order);

d = 0.5;
tol_xy = 0.5;
tol_xz = 0.3;
tol_yz = 0.3;
doseUnitLabel = 'Dose (eV/g)';
totalDoseUnitLabel = 'Dose total (eV/g)';

for k = 1:numel(files)
    dosePath = fullfile(groupDir, files(k).name);
    Scur = load_3d_dose_r2015(dosePath);
    if k == 1
        x = Scur(:,1);
        y = Scur(:,2);
        z = Scur(:,3);
        doseT = zeros(size(x));
        uTotal2 = zeros(size(x));
    end
    doseT = doseT + Scur(:,4);
    if size(Scur, 2) >= 5
        uTotal2 = uTotal2 + (Scur(:,5) .^ 2);
    end
end
uTotal = sqrt(uTotal2); %#ok<NASGU>

ix = find((abs(y - yT) <= d) .* (abs(z - zT) <= d));
iy = find((abs(x - xT) <= d) .* (abs(z - zT) <= d));
iz = find((abs(x - xT) <= d) .* (abs(y - yT) <= d));
i_xy = find((abs(z - zT) < tol_xy) .* (doseT > 1e-10));
i_xz = find((abs(y - yT) < tol_xz) .* (doseT > 1e-10));
i_yz = find((abs(x - xT) < tol_yz) .* (doseT > 1e-10));

fig = figure('Visible', 'off');
plot(x(ix), doseT(ix), 'k*');
xlabel('x (cm)'); ylabel('Dose (eV/g)'); title('Perfil de dose total ao longo de X'); legend('total'); grid on;
saveas(fig, fullfile(groupDir, '3d-dose_total_profile_x.png')); close(fig);

fig = figure('Visible', 'off');
plot(y(iy), doseT(iy), 'k*');
xlabel('y (cm)'); ylabel('Dose (eV/g)'); title('Perfil de dose total ao longo de Y'); legend('total'); grid on;
saveas(fig, fullfile(groupDir, '3d-dose_total_profile_y.png')); close(fig);

fig = figure('Visible', 'off');
plot(z(iz), doseT(iz), 'k*');
xlabel('z (cm)'); ylabel('Dose (eV/g)'); title('Perfil de dose total ao longo de Z'); legend('total'); grid on;
saveas(fig, fullfile(groupDir, '3d-dose_total_profile_z.png')); close(fig);

fig = figure('Visible', 'off');
scatter(x(i_xy), y(i_xy), 20, doseT(i_xy), 'filled');
hold on; [markerHandles, markerNames] = plot_selected_geometry_labels_r2015(labelSpecs, 'xy');
cb = colorbar; ylabel(cb, totalDoseUnitLabel); xlabel('x (cm)'); ylabel('y (cm)'); title(['Distribui' ced 'o total no plano XY (z = ', num2str(zT), ' cm)']); axis equal; grid on;
if ~isempty(markerHandles), legend(markerHandles, markerNames, 'Location', 'northeastoutside'); end; hold off;
saveas(fig, fullfile(groupDir, '3d-dose_total_xy.png')); close(fig);

fig = figure('Visible', 'off');
scatter(x(i_xz), z(i_xz), 20, doseT(i_xz), 'filled');
hold on; [markerHandles, markerNames] = plot_selected_geometry_labels_r2015(labelSpecs, 'xz');
cb = colorbar; ylabel(cb, totalDoseUnitLabel); xlabel('x (cm)'); ylabel('z (cm)'); title(['Distribui' ced 'o total no plano XZ (y = ', num2str(yT), ' cm)']); axis equal; grid on;
if ~isempty(markerHandles), legend(markerHandles, markerNames, 'Location', 'northeastoutside'); end; hold off;
saveas(fig, fullfile(groupDir, '3d-dose_total_xz.png')); close(fig);

fig = figure('Visible', 'off');
scatter(y(i_yz), z(i_yz), 20, doseT(i_yz), 'filled');
hold on; [markerHandles, markerNames] = plot_selected_geometry_labels_r2015(labelSpecs, 'yz');
cb = colorbar; ylabel(cb, totalDoseUnitLabel); xlabel('y (cm)'); ylabel('z (cm)'); title(['Distribui' ced 'o total no plano YZ (x = ', num2str(xT), ' cm)']); axis equal; grid on;
if ~isempty(markerHandles), legend(markerHandles, markerNames, 'Location', 'northeastoutside'); end; hold off;
saveas(fig, fullfile(groupDir, '3d-dose_total_yz.png')); close(fig);
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

legacyPlaneFiles = {
    fullfile(outDir, [filePrefix 'plane_XY_tumor.png']);
    fullfile(outDir, [filePrefix 'plane_XZ_tumor.png']);
    fullfile(outDir, [filePrefix 'plane_YZ_tumor.png']);
};
for legacyIdx = 1:numel(legacyPlaneFiles)
    if exist(legacyPlaneFiles{legacyIdx}, 'file')
        delete(legacyPlaneFiles{legacyIdx});
    end
end

relU = 100 * squeeze(U(:, :, izt))' ./ squeeze(D(:, :, izt))';
relU(~isfinite(relU) | squeeze(D(:, :, izt))' <= 1e-30) = NaN;
fig = figure('Color', 'w');
imagesc(xVec, yVec, relU);
axis xy equal tight;
cb = colorbar;
ylabel(cb, 'Incerteza relativa 3sigma (%)');
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
doseUnitLabel = 'Dose (eV/g)';
doseT = dose;
raw_ix = find((abs(y - yT) <= d) .* (abs(z - zT) <= d));
raw_iy = find((abs(x - xT) <= d) .* (abs(z - zT) <= d));
raw_iz = find((abs(x - xT) <= d) .* (abs(y - yT) <= d));
raw_i_xy = find((abs(z - zT) < tol_xy) .* (doseT > 1e-10));
raw_i_xz = find((abs(y - yT) < tol_xz) .* (doseT > 1e-10));
raw_i_yz = find((abs(x - xT) < tol_yz) .* (doseT > 1e-10));

plot_target_profile_r2015(x(raw_ix), doseT(raw_ix), 'x (cm)', 'Perfil de dose ao longo de X', fullfile(outDir, [plotStem '_profile_x.png']));
plot_target_profile_r2015(y(raw_iy), doseT(raw_iy), 'y (cm)', 'Perfil de dose ao longo de Y', fullfile(outDir, [plotStem '_profile_y.png']));
plot_target_profile_r2015(z(raw_iz), doseT(raw_iz), 'z (cm)', 'Perfil de dose ao longo de Z', fullfile(outDir, [plotStem '_profile_z.png']));

fig = figure('Color', 'w');
scatter(x(raw_i_xy), y(raw_i_xy), 20, doseT(raw_i_xy), 'filled');
hold on;
[markerHandles, markerNames] = plot_selected_geometry_labels_r2015(labelSpecs, 'xy');
cb = colorbar;
ylabel(cb, doseUnitLabel);
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
cb = colorbar;
ylabel(cb, doseUnitLabel);
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
cb = colorbar;
ylabel(cb, doseUnitLabel);
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
cb = colorbar;
ylabel(cb, 'Dose (eV/g)');
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

function selectedPaths = choose_path_subset_r2015(paths, dialogTitle, displayRoot)
selectedPaths = {};
if isempty(paths)
    return;
end
if numel(paths) == 1
    selectedPaths = paths;
    return;
end

choice = menu(dialogTitle, 'Use all found items', 'Choose subset', 'Skip this step');
if choice == 1
    selectedPaths = paths;
    return;
elseif choice ~= 2
    return;
end

labels = paths;
if nargin >= 3 && ~isempty(displayRoot)
    rootPrefix = [displayRoot filesep];
    prefixLen = numel(rootPrefix);
    for i = 1:numel(paths)
        if numel(paths{i}) >= prefixLen && strcmpi(paths{i}(1:prefixLen), rootPrefix)
            labels{i} = paths{i}(prefixLen + 1:end);
        end
    end
end

[idx, ok] = listdlg( ...
    'PromptString', dialogTitle, ...
    'ListString', labels, ...
    'SelectionMode', 'multiple', ...
    'ListSize', [900 360], ...
    'Name', dialogTitle);
if ok && ~isempty(idx)
    selectedPaths = paths(idx);
end
end

function name = short_name_r2015(pathValue)
[~, name, ext] = fileparts(pathValue);
name = [name ext];
if isempty(name)
    name = pathValue;
end
end

function plot_target_profile_r2015(axisCoords, doseVals, axisLabel, plotTitle, outPath)
if isempty(axisCoords) || isempty(doseVals)
    return;
end
roundedAxis = round(axisCoords * 1e6) / 1e6;
[uniqueAxis, ~, groupIdx] = unique(roundedAxis);
meanDose = accumarray(groupIdx, doseVals, [], @mean);
sampleCount = accumarray(groupIdx, 1, [], @sum);
[uniqueAxis, order] = sort(uniqueAxis);
meanDose = meanDose(order);
sampleCount = sampleCount(order); %#ok<NASGU>

fig = figure('Color', 'w');
plot(axisCoords, doseVals, '.', 'Color', [0.45 0.45 0.45], 'MarkerSize', 8);
hold on;
plot(uniqueAxis, meanDose, 'k-', 'LineWidth', 1.5);
plot(uniqueAxis, meanDose, 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4);
xlabel(axisLabel);
ylabel('Dose (eV/g)');
title(plotTitle);
legend('amostras perto do alvo', ['m' char(233) 'dia por corte'], 'Location', 'best');
grid on;
hold off;
saveas(fig, outPath);
close(fig);
end

function [handles, names] = plot_selected_geometry_labels_r2015(labelSpecs, planeMode)
handles = [];
names = {};
if isempty(labelSpecs)
    return;
end
palette = lines(max(1, size(labelSpecs, 1) - 1));
bodyCounter = 0;
for idx = 1:size(labelSpecs, 1)
    row = labelSpecs(idx, :);
    if numel(row) == 1 && iscell(row{1})
        row = row{1};
    end
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
    markerMode = lower(strtrim(char(marker)));
    if strcmp(markerMode, 'target') || strcmp(markerMode, 'o')
        h = plot(aVal, bVal, 'o', 'MarkerSize', 9, 'LineWidth', 1.6, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'w', 'Color', 'k');
    else
        bodyCounter = bodyCounter + 1;
        clr = palette(1 + mod(bodyCounter - 1, size(palette, 1)), :);
        h = plot(aVal, bVal, 'o', 'MarkerSize', 8, 'LineWidth', 1.4, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', clr, 'Color', clr);
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
