# MATLAB-YOLOv4-esfrChart
使用esfrChart製作訓練YOLOv4的DataSet

檔案介紹
---
* 對輸入影像使用內建的偵測方法偵測並得到座標，再將影像剪裁， 並檢查有哪些座標在剪裁的小影像中，將座標更新，並儲存成YOLOv4可以訓練的dataset資訊
    * cut_samll_enh.m : for enhanced版本的test chart
    * cut_samll_ext.m : for extended版本的test chart
    * cut_samll_sta.m : for stardand版本的test chart
* 對指定資料夾內的所有影像使用內建的偵測方法偵測並得到座標，並儲存成YOLOv4可以訓練的dataset資訊
    * label_enh.m : for enhanced版本的test chart
    * label_ext.m : for extended版本的test chart
    * label_sta.m : for stardand版本的test chart
* sfr_hao_tr.m : 上面六個程式會用到的function。修改了一些[原始程式碼](https://ww2.mathworks.cn/help/images/ref/plotsfr.html)

參考網站
---
[Plot spatial frequency response of edge - MATLAB plotSFR - MathWorks](https://ww2.mathworks.cn/help/images/ref/plotsfr.html)