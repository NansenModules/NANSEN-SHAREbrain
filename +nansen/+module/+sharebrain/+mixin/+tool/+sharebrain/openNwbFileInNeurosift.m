function openNwbFileInNeurosift()

    baseUrl = nansen.module.sharebrain.constants.NeurosiftBaseUrl;
    
    fileUrl = inputdlg('Please enter dataproxy api url:');
    
    finalUrl = baseUrl + "&url=" + fileUrl;

    web(finalUrl, '-browser')
end
