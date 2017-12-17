var api = api || {

	copyToClipboard: function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
		return window.SmartJSDemoInterface.copyToClipboard("复制到剪贴板的内容［测试专用］");
	},

	setWebViewTitle: function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
		return window.SmartJSDemoInterface.setWebViewTitle("设置标题［测试专用］");
	},

	login: function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
		return window.SmartJSDemoInterface.login();
	},

	logout: function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
		return window.SmartJSDemoInterface.logout();
	},

	getLoginInfo: function()
	{

		 if(undefined == window.SmartJSDemoInterface) return '{}';
         return window.SmartJSDemoInterface.getLoginInfo();
	},

	finish: function()
	{
		 if(undefined == window.SmartJSDemoInterface) return;
         return window.SmartJSDemoInterface.finish();
	},

	openInSystemBrowser : function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
         return window.SmartJSDemoInterface.openLocalPage('','','20','http://www.lessney.com');
	},

	openUrlInNewWindow : function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
         return window.SmartJSDemoInterface.openLocalPage('','','3','http://www.lessney.com');
	},

	openQRWindow : function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
         return window.SmartJSDemoInterface.openLocalPage('','','17','');
	},

	openCoolMallDetailWindow  : function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
         return window.SmartJSDemoInterface.openLocalPage('','','100','http://kuwan.snail.com/wap/ios/tmpl/product_detail.html?goods_id=100231&isHideActionbar=true');
	},

	share : function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
         return window.SmartJSDemoInterface.share('分享标题', '分享描述', 'http://www.lessney.com', 'http://www.lessney.com/wp-content/uploads/2015/07/weichat.png');
	},

	setShare: function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
         return window.SmartJSDemoInterface.setShare('分享标题', '分享描述', 'http://www.lessney.com', 'http://www.lessney.com/wp-content/uploads/2015/07/weichat.png');
	},	

	getUserInfo: function()
	{
		 if(undefined == window.SmartJSDemoInterface) return '{}';
         return window.SmartJSDemoInterface.getUserInfo();
	},

	getDeviceInfo: function()
	{
		 if(undefined == window.SmartJSDemoInterface) return '{}';
         return window.SmartJSDemoInterface.getDeviceInfo();
	},

	getBehaviourInfo: function()
	{
		if(undefined == window.SmartJSDemoInterface) return '{}';
         return window.SmartJSDemoInterface.getBehaviourInfo();
	},

	getContractAuth: function()
	{
		if(undefined == window.SmartJSDemoInterface) return '{}';
         return window.SmartJSDemoInterface.getContractAuth();
	},

	getNetStatus: function()
	{
		if(undefined == window.SmartJSDemoInterface) return '{}';
         return window.SmartJSDemoInterface.getNetStatus();
	},

	getNetEnv: function()
	{
		if(undefined == window.SmartJSDemoInterface) return '{}';
         return window.SmartJSDemoInterface.getNetEnv();
	},

	showWebViewShoppingCartButton : function()
	{
		if(undefined == window.SmartJSDemoInterface) return '{}';
         return window.SmartJSDemoInterface.showWebViewShoppingCartButton('1');
	},

	browseArtworkfromIndex: function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
         return window.SmartJSDemoInterface.browseArtworkfromIndex('http://upload-images.jianshu.io/upload_images/1403792-721ebac7c8c4b34d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/720/q/100,http://upload-images.jianshu.io/upload_images/2033515-05b607bf4127030d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240,http://upload-images.jianshu.io/upload_images/1866241-9a130647c4c5866e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240','0');
	},

	chooseContact: function(param)
	{
		if(undefined == window.SmartJSDemoInterface) return;
		return window.SmartJSDemoInterface.chooseContact(param);
	},

	snailpayAction: function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
		return window.SmartJSDemoInterface.snailpayAction('1','2','3','4','5','6','7','8','9');
	},
	openFaceDetect: function()
	{
		if(undefined == window.SmartJSDemoInterface) return;
		return window.SmartJSDemoInterface.openFaceDetect();
	},
};
