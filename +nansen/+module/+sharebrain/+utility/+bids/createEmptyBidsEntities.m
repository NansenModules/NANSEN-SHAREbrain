function bidsEntities = createEmptyBidsEntities()
%createEmptyBidsEntities - Blank set of BIDS filename entities
%   bidsEntities = createEmptyBidsEntities() returns a struct with one
%   field per supported BIDS entity, each set to missing. Assign the
%   entities that apply and pass the struct to createBidsFilename, which
%   leaves out every field still set to missing.
%
%   See also createBidsFilename

    bidsEntities = struct();
    bidsEntities.sub = missing;
    bidsEntities.ses = missing;
    bidsEntities.cohort = missing;
    bidsEntities.sample = missing;
    bidsEntities.run = missing;
    bidsEntities.task = missing;
    bidsEntities.desc = missing;
end
