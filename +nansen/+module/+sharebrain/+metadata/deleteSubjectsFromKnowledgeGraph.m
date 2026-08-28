function deleteSubjectsFromKnowledgeGraph(collection)
%deleteSubjectsFromKnowledgeGraph - Delete subjects and their groups
%   deleteSubjectsFromKnowledgeGraph(COLLECTION) deletes every Subject
%   and every SubjectGroup of COLLECTION from the EBRAINS Knowledge
%   Graph, removes them from COLLECTION, and saves COLLECTION.
%
%   Deletion from the Knowledge Graph is permanent and is not undone by
%   reverting the local collection. SubjectGroups are deleted before the
%   Subjects that reference them.
%
%   See also createSubjects, getOpenMINDSCollection

    sg = collection.list("SubjectGroup");
    for i = 1:numel(sg)
        kgdelete(sg(i).id)
        collection.remove(sg(i))
    end

    s = collection.list("Subject");
    for i = 1:numel(s)
        kgdelete(s(i).id)
        collection.remove(s(i))
    end
    collection.save()
end
