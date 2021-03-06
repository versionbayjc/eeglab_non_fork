% adding path for testing
% -----------------------

clear;
eeglab;
close;
clear;
[~,curFolder] = fileparts(pwd);

try
    ismatlabflag = ismatlab;
catch
    ismatlabflag = 1;
end

excludeFiles = { 'runtest.m' 'scanfoldersendemail.m' ...
    'ds002718' 'unittesting_tutorial' 'unittesting_common' 'unittesting_limo' ...
    'runMUtests.m' 'generateWrapperTests.m'};

if ismatlabflag
    vers = eeg_getversion;
    if str2num(vers(1:2)) == 11
        % exclude for version 11
        excludeFiles = [ excludeFiles(:)' {'mmo'} % NOT IMPLEMENTED
            ];
    else
    end
else
    % exclude for Octave
    excludeFiles = { excludeFiles{:} 'mmo' 
        'eegplotold'       % graphical issues
        'eegplotsold'      % graphical issues
        'eegplotgold'      % graphical issues
        'eeglabexefolder'  % Compiled version of EEGLAB'
        'openbdf'          % issue with missing functionality of fread bit24
        'readbdf'          % issue with missing functionality of fread bit24
        'hist2'            % unknown hggroup property Vertices - histogram plotted differently
        'gradmap'          % Unknown interpolation method
        'pop_read_erpss'   % mex file issue
        'pop_signalstat'   % require stats library normfit (not implemented)
        'pop_eventstat'    % require stats library normfit (not implemented)
        'mapcorr'          % too slow
        'makehtml'         % error
        'textgui'          % error
        'copyaxis'         % seg fault
        };
end

% Current sub path
% ----------------
tmpp = pwd;
indSeparators = find(tmpp == filesep);
currentSubPath = tmpp(indSeparators(end)+1:end);

% performing testing
% ------------------
testcases = dir(pwd);
[testcases(:).folder] = deal(pwd);
error_list = runtestcase(testcases, excludeFiles, 0);
save('-mat', 'error_list.mat', 'error_list');
pathSave = '/home/arno/nemar/unittestresults';
if exist(pathSave, 'dir')
    pathSave = fullfile(pathSave, datestr(now, 'YY_mm_dd'));
    if ~exist(pathSave)
        try
            mkdir(pathSave);
        catch
            lasterror
            formaterrorlist('error_list.mat');
        end
    end
    formaterrorlist('error_list.mat', fullfile(pathSave, [ curFolder '.txt' ]));
else
    formaterrorlist('error_list.mat');
end

if is_sccn
    % get revision info
    % -----------------
    basedir = pwd;
    eeglabpwd = fileparts(which('eeglab'));
    cd(eeglabpwd);
    rev = evalc('!git describe'); 
    cd(basedir);
    tmpindx = find(rev== '-');
    if length(tmpindx) > 1
        rev = rev(1:tmpindx(2)-1);
    end
    revEEGLAB = eeg_getversion;
    revEEGLAB(find(revEEGLAB == ' '):end) = [];
    rev = [revEEGLAB ' GIT' rev];

    % Matlab version
    % --------------
    vers = version;
    ind1 = find(vers == '(')+1;
    ind2 = find(vers == ')')-1;
    vers = vers(ind1:ind2);

    % write info file (for web)
    % -------------------------
    eeglab_options;
    basedir = '/home/www/eeglab/unit_testing_results';
    datenow = datestr(now);
    datenow(datenow == ' ') = '_';
    fileName  = [ 'results_' datenow '.txt' ];
    errorFile = [ 'errors_' datenow '.txt' ];
    copyfile('error_list_formated.txt', fullfile(basedir, errorFile));
    fid = fopen(fullfile(basedir, fileName), 'w');
    fprintf(fid, '<tr>');
    fprintf(fid, ['<td>' datestr(now) '</td>' ]);
    fprintf(fid, ['<td>' computer '</td>' ]);
    fprintf(fid, ['<td>' vers '</td>' ]);
    fprintf(fid, ['<td>' rev '</td>' ]);
    if option_computeica, fprintf(fid, ['<td>x</td>' ]);
    else                  fprintf(fid, ['<td></td>' ]);
    end
    if option_single, fprintf(fid, ['<td>x</td>' ]);
    else              fprintf(fid, ['<td></td>' ]);
    end
    if option_memmapdata, fprintf(fid, ['<td>x</td>' ]);
    else                  fprintf(fid, ['<td></td>' ]);
    end
    if option_eegobject, fprintf(fid, ['<td>x</td>' ]);
    else                 fprintf(fid, ['<td></td>' ]);
    end
    if option_donotusetoolboxes, fprintf(fid, ['<td>x</td>' ]);
    else                         fprintf(fid, ['<td></td>' ]);
    end
    if isempty(error_list), fprintf(fid, ['<td>pass</td>' ]); 
    else                    fprintf(fid, ['<td><a href="unit_testing_results/' errorFile '">errors</a></td>' ]);
    end
    fprintf(fid, '</tr>');
    fclose(fid);

    % provide feedback to admin under Linux or OSX
    % --------------------------------------------
    [tmp, currentUser] = system('whoami');
    if ~contains(currentUser, 'arno')
        if ~isempty(error_list)
            system([ 'mail -n -s "' currentSubPath ' generated errors" arno@ucsd.edu < error_list_formated.txt' ]);
        else
            system([ 'echo "Do not forget to change revision number in Content.m" | mail -n -s "' currentSubPath ' no errors - ready to compile" arno@ucsd.edu' ]);
        end
    end
else
    disp('*******************');
    disp('Errors (if any) saved in error_list.mat');
    fprintf('%d errors\n', length(error_list));
end
