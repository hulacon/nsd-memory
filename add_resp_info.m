function dbl = add_resp_info(dbl)
% dbl = add_resp_info(dbl)
% 
% Reads in dbl struct generated by responses.tsv and adds new fields that might
% be of interest.
% 
% Adds the below exciting fields of potential interest:
% �	HMCFOUTCOME: shorthand for memory outcome on current trial (1=hit,
% 2=miss, 3=correct rejection, 4=false alarm).
% �	REP: repetition number for this image (0 is first presentation, 1 is
% second, etc).
% �	SESSRECENT: the distance in sessions between current presentation and
% most recent presentation.
% �	TIMERECENT: the distance in days between current presentation and most
% recent presentation.
% �	LOGSECRECENT: the distance in log seconds between current presentation and most
% recent presentation.
% �	HMCFRECENT: the memory outcome of the previous presentation of the
% current image.
% �	MEMORYNEXT: the distance in trials between current presentation and
% next presentation of this image.
% �	ISCORRNEXT: the memory outcome (0=miss, 1=hit) of the next presentation
% of this image.
% �	SESSFIRST: the distance in sessions between current presentation and
% the second most recent presentation.
% �	TIMEFIRST: the distance in days between current presentation and the
% second most recent presentation.
% �	LOGSECFIRST: the distance in log seconds between current presentation and the
% second most recent presentation.
% �	HMCFFIRST: the memory outcome of the second most recent presentation of 
% the current image.
% �	MEMORYLAST: the distance in trials between current presentation and
% the second next presentation of this image.
% �	ISCORRLAST: the memory outcome (0=miss, 1=hit) of the second next 
% presentation of this image.
% �	SAMERUNRECENT: is 1 if there is any repetition within the same run
% between current item and previous presentation.
% �	SAMERUNFIRST: is 1 if there is any repetition within the same run
% between current item and the second most recent presentation.
% �	SAMERUNBEFORE: is 1 if there is any repetition within the same run
% between most recent and the second most recent presentation.
% �	UNIQUESESS: is the number of unique sessions a stimuli appeared in.
% only calculated for rep = 2
%
% jbh 4/30/19



% calculate anything globally 
% N = length(nonnan(unique(dbl.SUBJECT)));
% dbl.nTrials=length(dbl.SUBJECT);


% preallocate:
dbl.HMCFOUTCOME=nan(size(dbl.SUBJECT));
dbl.REP=nan(size(dbl.SUBJECT));
% other info
hmcflut = [1 2; 3 4];
for nn = 1:length(dbl.SUBJECT)
    % things not dependent on response
    dbl.REP(nn)=2-sum([isnan(dbl.MEMORYRECENT(nn)) isnan(dbl.MEMORYFIRST(nn))]);
    
    % for those things predicated on response
    if isnan(dbl.RT(nn)), continue, end
    dbl.HMCFOUTCOME(nn)=hmcflut(2-dbl.ISOLD(nn),2-dbl.ISCORRECT(nn));
end

% % flag things presented for everyone 3 times so far...
% dbl.SEENBYALL=nan(size(dbl.x73KID));
% allIDs = unique(dbl.x73KID);
% for aa = 1:length(allIDs)
%     currID = allIDs(aa);
%     tally = sum(dbl.x73KID==currID);
%     if tally == 24
%         dbl.SEENBYALL(dbl.x73KID==currID)=true;
%     end
% end



% calculate info about recent/first info
% preallocate:
dbl.SESSRECENT=nan(size(dbl.MEMORYRECENT));
dbl.UNIQUESESS=nan(size(dbl.MEMORYRECENT));
dbl.UNIQUESESS12_21=nan(size(dbl.MEMORYRECENT));
dbl.SAMERUNRECENT=nan(size(dbl.MEMORYRECENT));
dbl.SAMERUNBEFORE=nan(size(dbl.MEMORYRECENT));
dbl.TIMERECENT=nan(size(dbl.MEMORYRECENT));
dbl.LOGSECRECENT=nan(size(dbl.MEMORYRECENT));
dbl.HMCFRECENT=nan(size(dbl.MEMORYRECENT));
dbl.MEMORYNEXT=nan(size(dbl.MEMORYRECENT));
dbl.ISCORRNEXT=nan(size(dbl.MEMORYRECENT));
dbl.SESSFIRST=nan(size(dbl.MEMORYFIRST));
dbl.SAMERUNFIRST=nan(size(dbl.MEMORYRECENT));
dbl.TIMEFIRST=nan(size(dbl.MEMORYFIRST));
dbl.LOGSECFIRST=nan(size(dbl.MEMORYFIRST));
dbl.HMCFFIRST=nan(size(dbl.MEMORYFIRST));
dbl.MEMORYLAST=nan(size(dbl.MEMORYFIRST));
dbl.ISCORRLAST=nan(size(dbl.MEMORYFIRST));
dbl.ZRT=nan(size(dbl.RT));

for vv = 1:length(dbl.SUBJECT)
    if isnan(dbl.MEMORYRECENT(vv))
        continue
    end
    dbl.SESSRECENT(vv)=dbl.SESSION(vv)-dbl.SESSION(vv-1-dbl.MEMORYRECENT(vv));
    if dbl.SESSRECENT(vv)==0
        dbl.SAMERUNRECENT(vv)=dbl.RUN(vv)==dbl.RUN(vv-1-dbl.MEMORYRECENT(vv));
    end
    if dbl.SAMERUNRECENT(vv-1-dbl.MEMORYRECENT(vv))==1
       dbl.SAMERUNBEFORE(vv)=true;
    end
    dbl.TIMERECENT(vv)=dbl.TIME(vv)-dbl.TIME(vv-1-dbl.MEMORYRECENT(vv));
    dbl.LOGSECRECENT(vv) = log(dbl.TIMERECENT(vv) * 24 * 60 * 60);
    dbl.HMCFRECENT(vv)=dbl.HMCFOUTCOME(vv-1-dbl.MEMORYRECENT(vv));
    dbl.MEMORYNEXT(vv-1-dbl.MEMORYRECENT(vv))=dbl.MEMORYRECENT(vv);
    dbl.ISCORRNEXT(vv-1-dbl.MEMORYRECENT(vv))=dbl.ISCORRECT(vv);
    if isnan(dbl.MEMORYFIRST(vv))
        continue
    end
    dbl.SESSFIRST(vv)=dbl.SESSION(vv)-dbl.SESSION(vv-1-dbl.MEMORYFIRST(vv));
    if dbl.SESSFIRST(vv)==0
        dbl.SAMERUNFIRST(vv)=dbl.RUN(vv)==dbl.RUN(vv-1-dbl.MEMORYRECENT(vv));
        dbl.UNIQUESESS(vv) = 1;
        dbl.UNIQUESESS12_21(vv) = 0;
    elseif dbl.SESSFIRST(vv)>0
        if dbl.SESSRECENT(vv) == dbl.SESSFIRST(vv) || dbl.SESSRECENT(vv) == 0
            dbl.UNIQUESESS(vv) = 2;
            if dbl.SESSRECENT(vv) == dbl.SESSFIRST(vv)
                dbl.UNIQUESESS12_21(vv) = 2;
            else
                dbl.UNIQUESESS12_21(vv) = 1;
            end
        elseif dbl.SESSRECENT(vv) ~= dbl.SESSFIRST(vv) && dbl.SESSRECENT(vv) ~= 0
            dbl.UNIQUESESS(vv) = 3;
            dbl.UNIQUESESS12_21(vv) = 3;
        end
    end
    dbl.TIMEFIRST(vv)=dbl.TIME(vv)-dbl.TIME(vv-1-dbl.MEMORYFIRST(vv));
    dbl.LOGSECFIRST(vv) = log(dbl.TIMEFIRST(vv) * 24 * 60 * 60);
    dbl.HMCFFIRST(vv)=dbl.HMCFOUTCOME(vv-1-dbl.MEMORYFIRST(vv));
    dbl.MEMORYLAST(vv-1-dbl.MEMORYFIRST(vv))=dbl.MEMORYFIRST(vv);
    dbl.ISCORRLAST(vv-1-dbl.MEMORYFIRST(vv))=dbl.ISCORRECT(vv);
end


% calculate any other things...





% 
% % session loop
% for nn = 1:N
%    nSess = max(dbl.SESSION(dbl.SUBJECT==nn));
%    for ss = 1:nSess
%     iica = dbl.SUBJECT==nn&dbl.SESSION==ss&~isnan(dbl.RT);
%     dbl.ZRT(iica) = zscore(dbl.RT(iica));
%     
%     
%    end
% end



% calculate subject specific things




