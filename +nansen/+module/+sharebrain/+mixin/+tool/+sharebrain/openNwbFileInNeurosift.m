function openNwbFileInNeurosift()

    baseUrl = nansen.module.sharebrain.constant.NeuroSiftBaseUrl();
    
    fileUrl = inputdlg('Please enter dataproxy api url:');
    
    finalUrl = baseUrl + "&url=" + fileUrl;

    web(finalUrl, '-browser')
end
