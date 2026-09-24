# SIM2.2 — Điều chế chiều dài kênh của NMOS 035

## Thiết lập mô phỏng

Mô phỏng sử dụng mô hình `NM` Level 8 BSIM3 và symbol `nmos_035` trong thư viện LTspice 035 được cung cấp. Cực source và bulk nối đất. Tỉ số kích thước được giữ cố định ở `W/L = 10` cho cả năm transistor.

Điện áp vượt ngưỡng mục tiêu là `VOV = 0,500 V`. Do điện áp ngưỡng hiệu dụng của mô hình thay đổi theo chiều dài kênh, điện áp cổng được hiệu chỉnh dựa trên giá trị `Vth` tại điểm làm việc của LTspice khi `VDS = 1,0 V`; sau đó đặt `VGS = Vth + VOV`. Netlist hiệu chỉnh nằm trong `SIM2_2_NMOS_VTH.cir`. Điện áp cổng được giữ cố định trong suốt quá trình quét đầu ra. Vì vậy, `VOV` được khớp tại điểm tham chiếu 1,0 V; mô hình có thể làm `Vth` thay đổi nhẹ khi `VDS` thay đổi.

| L (μm) | W (μm) | Vth tại VDS = 1 V (V) | VGS (V) | VOV (V) |
|---:|---:|---:|---:|---:|
| 1 | 10 | 0,536 | 1,036 | 0,500 |
| 2 | 20 | 0,518 | 1,018 | 0,500 |
| 5 | 50 | 0,506 | 1,006 | 0,500 |
| 10 | 100 | 0,502 | 1,002 | 0,500 |
| 20 | 200 | 0,500 | 1,000 | 0,500 |

Với mỗi transistor, LTspice quét `VDS` từ 0,6 V đến 2,0 V với bước 10 mV. Khoảng quét VDS bắt đầu từ 0,6 V, cao hơn VOV mục tiêu 0,5 V, nên đáp ứng điều kiện VDS ≥ VOV để transistor làm việc trong vùng bão hòa ở phép so sánh này.

## Phương pháp tính

Trong vùng bão hòa, sử dụng biểu thức gần đúng theo yêu cầu bài tập:

\[
I_D \approx I_{D0}(1+\lambda V_{DS}).
\]

Độ dốc và tung độ gốc được ước lượng từ dòng điện mô phỏng tại hai đầu khoảng quét:

\[
g_{ds}\approx\frac{I_D(2{,}0\,\mathrm V)-I_D(0{,}6\,\mathrm V)}{2{,}0-0{,}6},\qquad
I_{D0}\approx I_D(0{,}6\,\mathrm V)-0{,}6g_{ds},\qquad
\lambda\approx\frac{g_{ds}}{I_{D0}}.
\]

Tiếp theo, tính điện trở đầu ra tại `VDS = 1,3 V` theo công thức bài tập yêu cầu:

\[
r_o\approx\frac{1}{\lambda I_D(1{,}3\,\mathrm V)}.
\]

## Kết quả

| L (μm) | W (μm) | ID tại 1,3 V (μA) | Độ dốc gds (μS) | λ (V⁻¹) | ro (kΩ) |
|---:|---:|---:|---:|---:|---:|
| 1 | 10 | 158,037 | 3,489 | 0,022876 | 276,611 |
| 2 | 20 | 165,261 | 2,464 | 0,015263 | 396,453 |
| 5 | 50 | 169,485 | 1,729 | 0,010358 | 569,653 |
| 10 | 100 | 170,948 | 1,379 | 0,008162 | 716,706 |
| 20 | 200 | 171,633 | 1,097 | 0,006455 | 902,644 |

## Đồ thị

### Dòng máng theo điện áp máng–nguồn

![Đặc tuyến đầu ra của NMOS 035](SIM2_2_NMOS_ID_vs_VDS.png)

### Hệ số λ và điện trở đầu ra theo chiều dài kênh

![Hệ số lambda và điện trở đầu ra theo chiều dài kênh](SIM2_2_NMOS_lambda_ro_vs_L.png)

## Nhận xét

Khi `L` tăng từ 1 μm lên 20 μm, `λ` giảm từ 0,022876 V⁻¹ xuống 0,006455 V⁻¹, trong khi `ro` tăng từ 276,6 kΩ lên 902,6 kΩ. Các đường đặc tuyến đầu ra cũng phẳng hơn, cho thấy điều chế chiều dài kênh yếu đi khi kênh dài hơn. Xu hướng này phù hợp với lý thuyết: kênh dài làm giảm ảnh hưởng tương đối của điện áp máng lên chiều dài kênh và làm tăng điện trở đầu ra.

Dòng điện tại 1,3 V tăng nhẹ từ 158,0 μA lên 171,6 μA dù `W/L` và điện áp vượt ngưỡng đã hiệu chỉnh được giữ cố định. Đây là đặc tính của mô hình BSIM3 được cung cấp trên các kích thước đang xét; mô hình bình phương lý tưởng cho kênh dài sẽ dự đoán mức biến thiên nhỏ hơn.

## Các tệp sử dụng

- `SIM2_2_NMOS.asc` — schematic LTspice và phép quét đặc tuyến đầu ra theo từng chiều dài kênh.
- `SIM2_2_NMOS_VTH.cir` — netlist hiệu chỉnh điện áp ngưỡng tại `VDS = 1 V`.
- `SIM2_2_NMOS_ID_VDS.csv` — dữ liệu các đường đặc tuyến đầu ra dùng để vẽ đồ thị.
- `SIM2_2_NMOS_results.csv` — các thông số đã trích xuất và tính toán.
