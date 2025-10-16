function mustBeDataSharingCollabName(value)
% mustBeDataSharingCollabName - Ensure a name is formatted as a valid DSC name
    arguments
        value (1,1) string
    end

    dscPrefix = nansen.module.sharebrain.constants.DataSharingCollabPrefix;
    assert( startsWith(value, dscPrefix), ...
        'Data Sharing Collab name must start with "%s"', dscPrefix)

    uuid = extractAfter(value, dscPrefix);
    nansen.module.sharebrain.internal.validator.mustBeValidUUID(uuid)
end
