# SIM.2.2 — Điều chế chiều dài kênh của NMOS

Để mở mô phỏng, mở [`Simulation/SIM2_2_NMOS.asc`](Simulation/SIM2_2_NMOS.asc) bằng LTspice. Thư mục `Simulation/` gom schematic, netlist, model 035, symbol NMOS, dữ liệu CSV, đồ thị và các file `.raw`, `.log`, `.net`, cache LTspice sinh ra. Model và symbol nằm cạnh schematic nên không phụ thuộc đường dẫn riêng của máy.

Thư mục `Report/` chỉ chứa báo cáo Markdown và PDF:

- Tiếng Việt: [Markdown](Report/SIM2_2_NMOS_Report_VI.md) · [PDF](Report/SIM2_2_NMOS_Report_VI.pdf)
- Tiếng Anh: [Markdown](Report/SIM2_2_NMOS_Report.md) · [PDF](Report/SIM2_2_NMOS_Report.pdf)
- Hướng dẫn tự thao tác LTspice: [SIM2_2_LTspice_Huong_dan_tu_thao_tac.md](Report/SIM2_2_LTspice_Huong_dan_tu_thao_tac.md)

Schematic quét toàn bộ `VDS = 0–2 V` để thể hiện cả vùng triode và vùng bão hòa. Các phép tính `λ` và `ro` chỉ dùng đoạn bão hòa `0,6–2,0 V`.
