window.addEventListener('DOMContentLoaded', (event) => {
    let search = new PagefindUI({ 
        element: "#search", 
        showSubResults: true,
        sort: { date: "desc" },
        showImages: false,
        resetStyles: false,
        autofocus: true
    });
    let url = new URL(window.location);
    let query = new URLSearchParams(url.search);
    
    search.triggerSearch(query.get("q"));

    let input = search._pfs.$$.root
        .querySelectorAll(".pagefind-ui__search-input")[0];
        
    input.addEventListener("keyup", () => {
        query.set("q", input.value);
        url.search = query;
        history.pushState({}, '', url);
    });
});