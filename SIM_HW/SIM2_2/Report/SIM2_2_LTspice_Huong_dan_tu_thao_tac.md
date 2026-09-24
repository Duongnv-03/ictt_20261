# Hướng dẫn tự thao tác LTspice — SIM2.2

Tài liệu này hướng dẫn làm lại mô phỏng SIM2.2 trên LTspice chạy trực tiếp trên Windows hoặc qua Wine: tạo mạch, nạp model, nhập lệnh mô phỏng, chạy sweep, xem đồ thị và đọc kết quả.

## 1. Chuẩn bị thư mục

Các file mô phỏng nằm trong `../Simulation/`:

- `SIM2_2_NMOS.asc` — schematic mẫu.
- `5827_035.lib` — thư viện model NMOS/PMOS 035.
- `nmos_035.asy` — symbol NMOS tùy chỉnh.
- `SIM2_2_NMOS_ID_VDS.csv` — dữ liệu đặc tuyến từ 0 đến 2 V.
- `SIM2_2_NMOS_results.csv` — các thông số `λ` và `ro`.

Hãy mở schematic từ thư mục `Simulation`, vì LTspice sẽ tìm model và symbol tương đối với vị trí schematic. Không cần cài thư viện vào đường dẫn riêng của từng máy.

Để thực hành mà không ảnh hưởng file gốc, mở `SIM2_2_NMOS.asc`, chọn **File → Save As...**, rồi lưu thành `SIM2_2_NMOS_thuc_hanh.asc` ngay trong thư mục `Simulation`.

## 2. Hiểu mạch trước khi vẽ

Mạch gồm một NMOS, hai nguồn áp và các kết nối sau:

```text
                 VDS
                  +
                  │
                  D
             G ───M1
                  S ─── GND
                  B ─── GND
             VGS cấp giữa G và GND
```

Symbol `nmos_035` có thứ tự chân `D, G, S, B`. Cực source và bulk nối đất. Nguồn `VDS` nối từ drain xuống đất; nguồn `VGS` nối từ gate xuống đất.

Trong LTspice, dòng qua nguồn áp có quy ước đi vào cực dương của nguồn. Vì vậy dòng drain dương được đọc là `-I(VDS)`.

## 3. Tạo schematic mới

Nếu muốn tự vẽ từ trang trắng:

1. Mở LTspice, chọn **File → New Schematic**, rồi lưu trong thư mục `Simulation`.
2. Nhấn `F2`, tìm `nmos_035`, đặt symbol vào giữa trang.
3. Nếu `nmos_035` không xuất hiện, mở schematic mẫu trước, copy transistor `M1`, dán sang schematic mới và giữ hai file trong cùng thư mục `Simulation`.
4. Nhấn `F2`, đặt một linh kiện `voltage` bên trái làm nguồn gate và một linh kiện `voltage` bên phải làm nguồn drain.
5. Nhấn `G` để đặt ground. Nối source, bulk và cực âm của cả hai nguồn vào ground.
6. Dùng phím `W` để nối cực dương nguồn gate vào chân `G`, cực dương nguồn drain vào chân `D`.
7. Nhấp chuột phải nguồn gate: đặt tên instance `VGS`, **Value** là `{VBIAS}`.
8. Nhấp chuột phải nguồn drain: đặt tên instance `VDS`, **Value** là `0`.
9. Nhấp chuột phải transistor. Đặt model/value là `NM`, `Value2` là `W={WIDTH}`. Trong **Edit Attributes**, đặt `SpiceLine` là:

```text
L={LCH} AD={2u*WIDTH} AS={2u*WIDTH} PD={2*(2u+WIDTH)} PS={2*(2u+WIDTH)}
```

## 4. Thêm lệnh mô phỏng

Trong LTspice 26, nhấn phím dấu chấm `.` hoặc bấm biểu tượng `.t` màu đen trên thanh công cụ, rồi bấm vào vùng trống trên schematic. Hộp **Edit Text on the Schematic** mở ra; dán khối lệnh sau và bấm **OK**. Sau đó bấm thêm một lần để đặt hộp chữ, rồi nhấn `Esc`.

Nút **Simulate → Configure Analysis** dùng để tạo nhanh các lệnh phân tích như `.op`, `.dc`, `.tran` hoặc `.ac`. Các lệnh tùy chỉnh như `.include`, `.step`, `.param` và `.meas` phải được đặt bằng SPICE Directive.

```spice
.include "5827_035.lib"
.param VOV=0.5
.step param IDX 1 5 1
.param LCH=table(IDX,1,1u,2,2u,3,5u,4,10u,5,20u)
.param WIDTH={10*LCH}
.param VBIAS=table(IDX,1,1.036,2,1.018,3,1.006,4,1.002,5,1.000)
.dc VDS 0 2.0 0.01
.meas DC IDLOW FIND -I(VDS) AT=0.6
.meas DC IDHIGH FIND -I(VDS) AT=2.0
.meas DC GDS PARAM (IDHIGH-IDLOW)/1.4
.meas DC IDZERO PARAM IDLOW-GDS*0.6
.meas DC LAMBDA PARAM GDS/IDZERO
.meas DC IDMID FIND -I(VDS) AT=1.3
.meas DC ROUT PARAM 1/(LAMBDA*IDMID)
.option numdgt=12
```

Ý nghĩa các lệnh chính:

| Lệnh | Ý nghĩa |
|---|---|
| `.include` | Nạp model `NM` từ thư viện cùng thư mục. |
| `.step param IDX 1 5 1` | Chạy năm lần cho năm chiều dài kênh. |
| `LCH` | Chọn `L = 1, 2, 5, 10, 20 µm`. |
| `WIDTH` | Giữ `W/L = 10`. |
| `VBIAS` | Điện áp cổng đã hiệu chỉnh cho từng chiều dài. |
| `.dc VDS 0 2.0 0.01` | Quét toàn bộ đặc tuyến từ 0 đến 2 V, bước 10 mV. |
| `.meas` | Tự lấy dòng, độ dốc, `λ` và `ro` sau mô phỏng. |

`VOV = 0,5 V` là overdrive danh định. Các giá trị `VBIAS` đã được hiệu chỉnh tại `VDS = 1 V` sao cho `VGS − Vth ≈ 0,5 V` cho từng chiều dài.

### 4.1. Vì sao khối lệnh này hoạt động?

Nút `.t` chỉ đặt một hộp văn bản lên schematic. Khi bấm **Run**, LTspice nhận mỗi dòng bắt đầu bằng dấu chấm là một **SPICE Directive**, đọc chúng cùng với các linh kiện trên sơ đồ, rồi tạo netlist để giải mạch. Vì vậy `.t` không phải là một phép phân tích riêng; nó là cách nhập lệnh cho bộ mô phỏng.

Các dòng trong schematic tương đương với ý tưởng sau:

```text
VGS: đặt điện áp cổng bằng {VBIAS}
VDS: nguồn áp ở cực drain, được lệnh .dc quét
M1 : NMOS model NM, W={WIDTH}, L={LCH}
```

LTspice thay các biểu thức trong dấu ngoặc nhọn bằng giá trị tham số trước khi giải mạch. Ví dụ, nếu `IDX=3` thì:

```text
LCH   = 5u
WIDTH = 10 × 5u = 50u
VBIAS = 1.006 V
```

#### Dòng 1: nạp model

```spice
.include "5827_035.lib"
```

LTspice đọc file thư viện và tìm model có tên `NM`. Giá trị **Value** của transistor trong schematic cũng phải là `NM`; nếu tên không khớp, LTspice báo `Unknown model`.

#### Dòng 2: khai báo overdrive

```spice
.param VOV=0.5
```

Lệnh này tạo tham số `VOV = 0,5 V`. Trong schematic hiện tại, `VOV` dùng để ghi rõ mục tiêu thiết kế và giải thích cách chọn điện áp cổng; nó không tự động tính lại `VBIAS`. Các giá trị `VBIAS` bên dưới là bảng đã hiệu chỉnh riêng cho từng chiều dài từ kết quả `Vth`.

#### Dòng 3: tạo năm lần chạy

```spice
.step param IDX 1 5 1
```

LTspice chạy lại toàn bộ phân tích với `IDX = 1, 2, 3, 4, 5`. Mỗi giá trị `IDX` tạo một đường đặc tuyến riêng. Đây là vòng lặp bên ngoài; bên trong mỗi lần chạy còn có vòng quét `VDS`.

#### Dòng 4: chọn chiều dài kênh

```spice
.param LCH=table(IDX,1,1u,2,2u,3,5u,4,10u,5,20u)
```

Hàm `table(x, x1,y1, x2,y2, ...)` ánh xạ giá trị đầu vào sang giá trị đầu ra:

| `IDX` | `LCH` |
|---:|---:|
| 1 | 1 µm |
| 2 | 2 µm |
| 3 | 5 µm |
| 4 | 10 µm |
| 5 | 20 µm |

Ký hiệu `u` là micro, nên `1u = 1×10⁻⁶` theo đơn vị SI của SPICE.

#### Dòng 5: giữ tỷ số W/L

```spice
.param WIDTH={10*LCH}
```

Với mỗi lần chạy, bề rộng được đặt bằng `10×LCH`. Do đó `W/L = 10` cho cả năm transistor. Tham số này được dùng trong thuộc tính `W={WIDTH}` của M1 và trong các biểu thức diện tích/perimeter `AD`, `AS`, `PD`, `PS`.

#### Dòng 6: chọn điện áp cổng

```spice
.param VBIAS=table(IDX,1,1.036,2,1.018,3,1.006,4,1.002,5,1.000)
```

Bảng này trả về điện áp cấp cho nguồn `VGS`, vì giá trị nguồn trong schematic là `{VBIAS}`. Mỗi chiều dài có `VGS` hơi khác nhau để tại điểm tham chiếu `VDS = 1 V` đạt gần `VOV = VGS − Vth ≈ 0,5 V`. Trong một lần `.dc`, `VGS` giữ cố định; chỉ `VDS` thay đổi.

#### Dòng 7: quét điện áp drain

```spice
.dc VDS 0 2.0 0.01
```

Nguồn có tên `VDS` được quét từ `0 V` đến `2 V`, mỗi bước `0,01 V`. Mỗi giá trị `IDX` có `(2,0 − 0)/0,01 + 1 = 201` điểm. Với năm giá trị `IDX`, LTspice giải khoảng `5×201 = 1005` điểm làm việc và tạo năm đường `ID–VDS`.

Ở `VDS` nhỏ, transistor ở vùng triode; khi `VDS` vượt xấp xỉ `VGS−Vth ≈ VOV`, transistor chuyển sang vùng bão hòa. Vì vậy đồ thị được quét từ 0 để thấy toàn bộ đặc tuyến, nhưng phần tính `λ` chỉ lấy từ `0,6 V` trở lên.

#### Vì sao dùng `-I(VDS)`?

LTspice định nghĩa `I(VDS)` là dòng đi **vào cực dương** của nguồn áp. Trong mạch này dòng thực tế đi từ nguồn `VDS` vào drain rồi qua transistor xuống mass, tức là đi ra khỏi cực dương của nguồn. Vì thế LTspice ghi dòng nguồn là số âm và dòng drain được lấy bằng `ID = −I(VDS)`.

#### Các dòng `.meas`: lấy số liệu sau khi quét

```spice
.meas DC IDLOW FIND -I(VDS) AT=0.6
.meas DC IDHIGH FIND -I(VDS) AT=2.0
```

Sau khi hoàn tất đường quét, hai lệnh này lấy dòng tại `VDS = 0,6 V` và `VDS = 2,0 V`. Từ hai điểm đó, độ dốc trung bình trong vùng bão hòa là:

```spice
.meas DC GDS PARAM (IDHIGH-IDLOW)/1.4
```

Số `1.4` chính là `2,0−0,6`. Đại lượng này có đơn vị siemens:

```text
gds = ΔID/ΔVDS
```

Tiếp theo, kéo đường thẳng có độ dốc `GDS` ngược về `VDS = 0`:

```spice
.meas DC IDZERO PARAM IDLOW-GDS*0.6
```

Đây là dòng giao điểm ngoại suy `IDZERO`. Từ đó:

```spice
.meas DC LAMBDA PARAM GDS/IDZERO
```

áp dụng công thức `λ = gds/IDZERO`, với đơn vị `V⁻¹`. Các điểm dưới `0,6 V` không dùng trong phép tính này vì chúng còn chịu ảnh hưởng mạnh của vùng triode và điểm gối.

#### Dòng điện dùng để tính điện trở đầu ra

```spice
.meas DC IDMID FIND -I(VDS) AT=1.3
.meas DC ROUT PARAM 1/(LAMBDA*IDMID)
```

`1,3 V` là trung điểm của khoảng `0,6–2,0 V`, vì `(0,6 + 2,0)/2 = 1,3 V`. Đây là điểm phân cực đại diện do mô phỏng chọn, không phải giá trị bắt buộc của đề. Lệnh cuối dùng công thức `ro = 1/(λID)`. Nếu chọn một điểm `VDS` khác trong vùng bão hòa thì `ID` và kết quả `ro` sẽ thay đổi nhẹ.

#### Dòng cuối: số chữ số trong log

```spice
.option numdgt=12
```

Lệnh này yêu cầu SPICE in nhiều chữ số hơn trong **SPICE Error Log**. Nó cải thiện cách hiển thị kết quả, không biến mô hình thành chính xác tuyệt đối hơn.

### 4.2. Trình tự LTspice thực sự thực hiện

Khi bấm **Run**, có thể hình dung LTspice làm theo thứ tự:

1. Đọc schematic và file `5827_035.lib` để biết mạch gồm những linh kiện và model nào.
2. Chọn `IDX = 1`, tính `LCH`, `WIDTH`, `VBIAS`, rồi quét `VDS` từ 0 đến 2 V.
3. Tại từng điểm `VDS`, giải phương trình phi tuyến của NMOS để tìm điện áp nút và dòng điện.
4. Lưu đường cong `-I(VDS)` của lần chạy đó.
5. Thực hiện lại bước 2–4 cho `IDX = 2, 3, 4, 5`.
6. Sau mỗi đường quét, thực hiện các lệnh `.meas` và ghi kết quả vào **SPICE Error Log**.

Do đó một khối `.t` ngắn có thể tạo ra nhiều kết quả: `.step` tạo các trường hợp, `.dc` tạo các điểm trên mỗi trường hợp, còn `.meas` đọc dữ liệu đã tạo để tính các thông số cuối cùng.

## 5. Chạy và xem đồ thị

1. Nhấn **Run** hoặc `F9`.
2. Nếu báo thiếu model, kiểm tra schematic và `5827_035.lib` có cùng thư mục không.
3. Trong Waveform Viewer, nhấp vào dây drain hoặc chọn **Plot Settings → Add Trace...**.
4. Nhập `-I(VDS)` để vẽ dòng drain.
5. Dùng **View → Step Legend** để xem đường nào ứng với `IDX = 1...5`.

Đồ thị từ `VDS = 0` đến `2 V` có vùng triode ở điện áp thấp và vùng bão hòa khi `VDS` vượt xấp xỉ `VOV ≈ 0,5 V`. Toàn bộ dải được giữ lại để quan sát; khi tính `λ`, chỉ dùng đoạn `0,6–2,0 V`.

## 6. Đọc SPICE Error Log

Sau khi chạy, chọn **View → SPICE Error Log**. Các nhóm kết quả có ý nghĩa:

- `IDLOW`: `ID` tại `VDS = 0,6 V`.
- `IDHIGH`: `ID` tại `VDS = 2,0 V`.
- `GDS`: độ dốc trung bình trên đoạn `0,6–2,0 V`.
- `IDZERO`: giao điểm ngoại suy tại `VDS = 0`.
- `LAMBDA`: `GDS / IDZERO`.
- `IDMID`: `ID` tại `VDS = 1,3 V`.
- `ROUT`: `1 / (LAMBDA × IDMID)`.

Đề không quy định phải lấy `ID` tại `VDS` nào để tính `ro`. Báo cáo chọn `1,3 V`, là trung điểm của khoảng `0,6–2,0 V`, làm điểm phân cực đại diện. Chọn điểm khác trong vùng bão hòa sẽ cho `ro` hơi khác vì `ro = 1/(λID)` phụ thuộc vào dòng `ID`.

## 7. Tự kiểm tra phép tính

Ví dụ với `L = 1 µm`, đọc trong log:

```text
IDLOW  = 154.6159 µA
IDHIGH = 159.5005 µA
IDMID  = 158.0366 µA
```

```text
gds    = (159.5005 - 154.6159) µA / 1.4 V = 3.4890 µS
IDZERO = 154.6159 µA - 0.6 × 3.4890 µA = 152.5225 µA
lambda = 3.4890 µS / 152.5225 µA = 0.0228756 V^-1
ro     = 1 / (0.0228756 × 158.0366 µA) = 276.6 kΩ
```

## 8. Lỗi thường gặp

**Không tìm thấy `nmos_035`:** copy transistor `M1` từ schematic mẫu hoặc kiểm tra symbol nằm cùng thư mục.

**Unknown model `NM`:** thêm `.include "5827_035.lib"` và kiểm tra đúng tên model là `NM`.

**Không chạy được `.dc VDS`:** tên instance nguồn drain phải là `VDS`, không phải tên mặc định `V1`.

**Dòng hiển thị âm:** dùng `-I(VDS)` vì quy ước chiều dòng qua nguồn áp.

**Chỉ thấy một đường cong:** kiểm tra `.step param IDX 1 5 1`, `LCH`, `WIDTH` và `VBIAS`.

**Không thấy `.meas`:** chạy lại rồi mở **View → SPICE Error Log**.

## 9. Checklist

- [ ] Schematic và `5827_035.lib` cùng thư mục.
- [ ] Symbol là `nmos_035`, model là `NM`.
- [ ] Source và bulk nối ground.
- [ ] Nguồn gate tên `VGS`, nguồn drain tên `VDS`.
- [ ] Có `.include`, `.step`, `.dc` và các lệnh `.meas`.
- [ ] Đồ thị có năm đường cong từ `VDS = 0 V`.
- [ ] Khi tính `λ`, chỉ dùng đoạn `0,6–2,0 V`.
- [ ] Đã tự kiểm tra một dòng kết quả bằng công thức.
