window.SogouMse = window.SogouMse || {};
window.SogouMse.createNamespace = function(str){
　　var arr=str.split("."),o=window.SogouMse;
　　for(i=(arr[0]=="SogouMse")?1:0; i<arr.length; i++){
　　　　o[arr[i]]=o[arr[i]] || {};
　　　　o=o[arr[i]];
　　}
}
window.SogouMse.createNamespace("spaceInfo");
window.SogouMse.spaceInfo.info = "com.sogou.mse";