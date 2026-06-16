function bidsFilename = createBidsFilename(bidsEntities, bidsSuffix, fileExtension)

    arguments
        bidsEntities (1,1) struct
        bidsSuffix (1,1) string
        fileExtension (1,1) string = "nwb"
    end

    names = string( fieldnames(bidsEntities) );
    values = string( struct2cell(bidsEntities) );
    
    try
        isMissing = arrayfun(@(c) ismissing(c), values);
    catch
        keyboard
    end

    names(isMissing) = [];
    values(isMissing) = [];

    entities = compose("%s-%s", names, values);
    bidsFilename = sprintf("%s_%s.%s", strjoin(entities, '_'), bidsSuffix, fileExtension);
end
