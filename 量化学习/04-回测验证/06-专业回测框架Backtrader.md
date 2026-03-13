# 第六课：专业回测框架 Backtrader

> 更新日期：2026-03-13

---

## 6.1 为什么要用专业框架？

手写回测的缺点：
- 代码冗余
- 容易出错（特别是未来函数）
- 统计指标不全面
- 无法做多策略组合

**Backtrader** 是Python最流行的回测框架之一，帮你解决这些问题。

---

## 6.2 安装 Backtrader

```bash
pip install backtrader
```

---

## 6.3 Backtrader 核心概念

| 概念 | 含义 |
|-----|------|
| **Cerebro** | 大脑，负责执行回测 |
| **Strategy** | 策略，定义买卖逻辑 |
| **Data Feeds** | 数据源 |
| **Broker** | 券商模拟 |
| **Analyzers** | 分析器（计算指标） |

---

## 6.4 用 Backtrader 实现连扳策略

```python
import backtrader as bt
import akshare as ak
import pandas as pd
from datetime import datetime

# 1. 定义策略
class LianBanStrategy(bt.Strategy):
    """连扳接力策略"""

    params = (
        ('limit_pct', 9.9),    # 涨停幅度
        ('vol_ratio', 1.5),    # 成交量放大倍数
        ('ma_period', 20),     # 均线周期
    )

    def __init__(self):
        self.order = None
        self.buy_price = None
        self.buy_date = None

    def log(self, txt, dt=None):
        dt = dt or self.datas[0].datetime.date(0)
        print(f'{dt.isoformat()} {txt}')

    def notify_order(self, order):
        if order.status in [order.Submitted, order.Accepted]:
            return

        if order.status in [order.Completed]:
            if order.isbuy():
                self.log(f'买入成交，价格: {order.executed.price:.2f}')
            elif order.issell():
                self.log(f'卖出成交，价格: {order.executed.price:.2f}')

        self.order = None

    def next(self):
        # 需要至少N天数据
        if len(self) < self.params.ma_period + 2:
            return

        # 获取昨天和今天的数据
        yesterday = self.datas[0].close[-1]
        today_close = self.datas[0].close[0]
        today_open = self.datas[0].open[0]
        today_volume = self.datas[0].volume[0]

        # 计算昨日涨跌幅
        yesterday_change = (yesterday - self.datas[0].close[-2]) / self.datas[0].close[-2] * 100

        # 计算成交量均线
        vol_ma5 = sum(self.datas[0].volume.get(-1, 5)) / 5
        volume_ratio = today_volume / vol_ma5

        # 计算MA20
        ma20 = sum(self.datas[0].close.get(-1, self.params.ma_period)) / self.params.ma_period

        # 买入条件：昨天涨停 + 今天有换手 + 成交量放大 + 站上MA20
        if not self.position:  # 没有持仓
            if (yesterday_change >= self.params.limit_pct and
                today_open < today_close and  # 非一字板
                volume_ratio > self.params.vol_ratio and
                today_close > ma20):

                self.log(f'买入信号: 昨日涨幅{yesterday_change:.1f}%, 量比{volume_ratio:.2f}')
                self.order = self.buy()

        # 卖出条件：次日开盘卖出
        else:
            # 持有1天后卖出
            if len(self) - self.buy_date >= 2:
                self.log('卖出信号: 持有1天后卖出')
                self.order = self.sell()


# 2. 准备数据（从akshare转换）
def get_data_from_akshare(stock_code, start_date, end_date):
    df = ak.stock_zh_a_hist(
        symbol=stock_code,
        period='daily',
        start_date=start_date,
        end_date=end_date
    )

    df = df.sort_values('日期')
    df['date'] = pd.to_datetime(df['日期'])

    # 转换格式
    df['datetime'] = df['date']
    df['open'] = df['开盘'].astype(float)
    df['high'] = df['最高'].astype(float)
    df['low'] = df['最低'].astype(float)
    df['close'] = df['收盘'].astype(float)
    df['volume'] = df['成交量'].astype(float)
    df['openinterest'] = -1

    df = df[['datetime', 'open', 'high', 'low', 'close', 'volume', 'openinterest']]
    df.set_index('datetime', inplace=True)

    return df


# 3. 运行回测
cerebro = bt.Cerebro()

# 添加数据
df = get_data_from_akshare('600519', '20230101', '20231231')
data = bt.feeds.PandasData(dataname=df)
cerebro.adddata(data)

# 添加策略
cerebro.addstrategy(LianBanStrategy)

# 设置初始资金
cerebro.broker.setcash(100000.0)

# 添加分析器
cerebro.addanalyzer(bt.analyzers.SharpeRatio, _name='sharpe')
cerebro.addanalyzer(bt.analyzers.DrawDown, _name='drawdown')
cerebro.addanalyzer(bt.analyzers.Returns, _name='returns')

# 运行
print(f'初始资金: {cerebro.broker.getvalue():.2f}')
results = cerebro.run()
print(f'最终资金: {cerebro.broker.getvalue():.2f}')

# 输出分析结果
strategy = results[0]
print(f'\n收益率: {strategy.analyzers.returns.get_analysis()["rtot"]*100:.2f}%')
print(f'夏普比率: {strategy.analyzers.sharpe.get_analysis()["sharperatio"]:.2f}')
print(f'最大回撤: {strategy.analyzers.drawdown.get_analysis()["max"]["drawdown"]:.2f}%')
```

---

## 6.5 多股票批量回测

```python
# 添加多只股票
test_stocks = ['600519', '000858', '601318', '300750', '002594']

for stock in test_stocks:
    try:
        df = get_data_from_akshare(stock, '20230101', '20231231')
        data = bt.feeds.PandasData(dataname=df)
        cerebro.adddata(data)
    except Exception as e:
        print(f"获取{stock}数据失败: {e}")

# 这样所有股票会用同一个策略运行
cerebro.run()
```

---

## 6.6 参数优化

Backtrader 可以自动测试不同参数组合：

```python
# 优化参数
cerebro.optstrategy(
    LianBanStrategy,
    limit_pct=range(9, 11),      # 9% - 10%
    vol_ratio=range(10, 20, 5),  # 1.0 - 2.0，步长0.5
    ma_period=range(10, 30, 5)   # 10 - 30，步长5
)

results = cerebro.run()
```

---

## 本课重点

1. **Backtrader** - Python最流行的回测框架
2. **核心组件**：Cerebro（大脑）、Strategy（策略）、Broker（券商模拟）
3. **优势**：规范、多分析器、支持参数优化

---

## 下节预告

第七课：实盘交易接口介绍（如何把策略连接到真实券商账户）
