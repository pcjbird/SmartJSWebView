function SmartJSGetHTMLElementsAtPoint(x,y)
{
    var tags = ",";
    var e = document.elementFromPoint(x,y);
    while (e)
    {
        if (e.tagName) 
        {
            tags += e.tagName + ',';
        }
        e = e.parentNode;
    }
    return tags;
}
            
function SmartJSGetFirstImage()
{
    var imgs = document.getElementsByTagName('img');
    for(var i = 0; i < imgs.length; i += 1)
    {
        if(imgs[i].width > 200)
        {
            return imgs[i].src;
        }
    }
    return undefined;
}
