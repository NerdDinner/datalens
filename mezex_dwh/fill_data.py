import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
import uuid
from sqlalchemy import create_engine

# 1. ГЕНЕРАЦИЯ ДАННЫХ
np.random.seed(42)
random.seed(42)
n_users = 1000
start_date = datetime(2026, 1, 1)

client_ids = [f"ym_{random.randint(100000000, 999999999)}" for _ in range(n_users)]
user_guids = [str(uuid.uuid4()) for _ in range(n_users)]

metrika_data, backend_data, leads_1c_data = [], [], []
utm_sources = ['yandex', 'google', 'vk_ads', 'tg_channel', 'direct']
utm_mediums = ['cpc', 'cpc', 'cpm', 'post', 'none']

# Заполняем визиты Метрики
for i in range(1500):
    user_idx = random.randint(0, n_users - 1)
    cid = client_ids[user_idx]
    src_idx = random.randint(0, len(utm_sources) - 1)
    v_date = start_date + timedelta(days=random.randint(0, 150), hours=random.randint(0, 23))
    metrika_data.append({
        'visit_id': f"v_{1000000 + i}", 'client_id': cid, 'visit_datetime': v_date,
        'utm_source': utm_sources[src_idx], 'utm_medium': utm_mediums[src_idx],
        'utm_campaign': f"camp_{random.randint(1, 5)}" if utm_sources[src_idx] != 'direct' else 'none'
    })
df_metrika = pd.DataFrame(metrika_data)

# Заполняем логи бэкенда по воронке
for _, row in df_metrika.iterrows():
    cid, uid, v_time = row['client_id'], user_guids[client_ids.index(row['client_id'])], row['visit_datetime']
    backend_data.append({'log_datetime': v_time + timedelta(seconds=15), 'user_guid': uid, 'client_id': cid, 'api_method': '/api/v1/page_view', 'status_code': 200})
    if random.random() < 0.4:
        backend_data.append({'log_datetime': v_time + timedelta(minutes=2), 'user_guid': uid, 'client_id': cid, 'api_method': '/api/v1/cart_add', 'status_code': 200})
        if random.random() < 0.5:
            backend_data.append({'log_datetime': v_time + timedelta(minutes=5), 'user_guid': uid, 'client_id': cid, 'api_method': '/api/v1/checkout', 'status_code': 200})
            rand_val = random.random()
            if rand_val < 0.7:
                backend_data.append({'log_datetime': v_time + timedelta(minutes=10), 'user_guid': uid, 'client_id': cid, 'api_method': '/api/v1/create_lead', 'status_code': 200})
            elif rand_val < 0.9:
                backend_data.append({'log_datetime': v_time + timedelta(minutes=10), 'user_guid': uid, 'client_id': cid, 'api_method': '/api/v1/create_lead', 'status_code': 500})
df_backend = pd.DataFrame(backend_data)

# Заполняем 1С Лиды
success_leads = df_backend[df_backend['api_method'] == '/api/v1/create_lead']
statuses = ['Новый', 'В работе', 'Счет выставлен', 'Сделка закрыта', 'Отказ']
weights = [0.1, 0.3, 0.2, 0.3, 0.1]
for idx, row in success_leads.iterrows():
    status = np.random.choice(statuses, p=weights)
    leads_1c_data.append({
        'lead_id': f"1C-{10000 + idx}", 'user_guid': row['user_guid'],
        'created_datetime': row['log_datetime'] + timedelta(minutes=5), 'current_status': status,
        'revenue': random.randint(15000, 120000) if status in ['Счет выставлен', 'Сделка закрыта'] else 0
    })
df_1c = pd.DataFrame(leads_1c_data)

# 2. ЗАПИСЬ В POSTGRES
engine = create_engine(
    'postgresql://analyst:SecretPassword789@127.0.0.1:5439/dwh_analytics',
    connect_args={'client_encoding': 'utf8'}
)

df_metrika.to_sql('raw_metrika', engine, if_exists='append', index=False)
df_backend.to_sql('raw_backend_logs', engine, if_exists='append', index=False)
df_1c.to_sql('raw_1c_leads', engine, if_exists='append', index=False)
print("Данные успешно сгенерированы и записаны!")
