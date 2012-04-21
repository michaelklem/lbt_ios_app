I. Tale gồm những thông tin

1/  index: id của tale, được tạo bởi công thức, khi upload lên server, id của tale trên server == index 

index = round([[NSDate date] intervalSince1970]  * 100 + rand(10,99)

2/ title: title cho tale  

3/ created = round([[NSDate date] timeIntevalSince1970]
Ngày tạo tale: được save dưới dạng double == time interval từ 1970 đến thời điểm hiện tại

4/ modified: same with created
Tương tự created 

5/pages: array of pages 
Mảng pages chứa các pages của tale 



II. Page 
1/ index: Tương tự index của tale, đây là id của từng page

2/ imgPath: Đường dẫn tới ảnh
Nếu imgPath == "" => không có ảnh 
Quy tắc save ảnh: 

.../yyyy/mm/dd/taleindex/pageindex/images/index.jpg 

với .../ => đường dẫn tới thư mục documents của app
/images/ -> cố định cho ảnh 
/yyyy/ năm (created date cua tale)
/mm/ tháng (created date cua tale)
/dd/ ngày (created date cua tale)
index là file name 
.jpg là format của ảnh 

3/ voicePath: Đường dẫn tới tệp voice 
nếu voicePath == "" => không có voice cho page 
Quy tắc: 
.../yyyy/mm/dd/taleindex/pageindex/voices/index.jpg 

4/ text: text 


5/ order: thứ tự page trong tale 

6/ time: default = 0, khi co voice thi se = thoi gian cua voice. Luu thong tin nay lai de khi play ko phai read file voice nua.

III. Save to file 

Tale + page của tale được save trong .plist, ảnh + voice được save trong thư mục theo quy tăc trên 


IV. Khi xoá một tale 

1/ remove tale trong list tale 
2/ Xoá ảnh + voice của các page
3/ release object trong bộ nhớ 


V. Khi xoá một page 

1/ remove page ra list cac tale 
3/ copy page object tới một stack undo (một array)
2/ Khi thoát trang edit tale or khởi tạo trang edit tale thì xoá images + voices của các page trong danh sách bị xoá 
3/ save vào plist
5/ Khi undo xoá một tale: 
- copy page về list pages của tale với order cũ
- sort lại pages của tale theo thứ tự order 

VI: 
Khi có ảnh mới + voice mới cho một page ==> Ghi đè lên tệp cũ đã tạo

  

