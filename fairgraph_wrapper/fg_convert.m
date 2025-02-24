sub = openminds.core.Subject();
sub.biologicalSex = "male";
sub.lookupLabel = 'pvs_sleep-08';
sub.species = 'musMusculus';

fgSub = convertToFairgraphObject(sub, fgClient);
fgSub.save(fg_client, space="collab-d-2b5e1b5d-68ac-49c2-9189-33277dd471ec")

sub = py.fairgraph.openminds.core.Subject();
sub = sub.from_id('8281b8ab-60b0-4d2f-8cf4-0843ce09d621', fg_client, scope="in progress");