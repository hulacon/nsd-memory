
function resp = filter_resp(resp,varargin)
% resp = filter_resp(resp,'RESPFIELDNAME',inclusionCriteria,...)
%
% filters resp struct to only keep values which meet all inclusionCriteria
% across the various specified fields
%
% jbh 9/23/19

keep = true(size(resp.SUBJECT));
for vv = 1:2:length(varargin)
   keep = keep & ismember(resp.(varargin{vv}),varargin{vv+1}); 
end

rfn = fieldnames(resp);
for rr = 1:length(rfn)
   resp.(rfn{rr}) = resp.(rfn{rr})(keep);
end
