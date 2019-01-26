import dash
from dash.dependencies import Input, Output
import dash_core_components as dcc
import dash_html_components as html
import dash_table
import pandas as pd
import psycopg2
import os

db_host = 'localhost'
db_password = 'postgres'


class Constants:
    q1_name = 'Joo Lee'
    q1_color = 'white'
    q1_plate = '%AA%'

    q2_date = '2018-11-21'

    q4_name = 'Manuel Mazzara'

    q5_date = '2018-11-21'

    q8_date = '2018-11-21'

    @staticmethod
    def get_list_params(number):
        if number == 1:
            return [Constants.q1_name, Constants.q1_color, Constants.q1_plate]
        if number == 2:
            return [Constants.q2_date]
        if number == 4:
            return [Constants.q4_name]
        if number == 5:
            return [Constants.q5_date, Constants.q5_date]
        if number == 8:
            return [Constants.q8_date]
        return None

    @staticmethod
    def get_constant(constant):
        if constant == 'q1_n':
            return Constants.q1_name
        if constant == 'q1_c':
            return Constants.q1_color
        if constant == 'q1_p':
            return Constants.q1_plate
        if constant == 'q2_d':
            return Constants.q2_date
        if constant == 'q4_n':
            return Constants.q4_name
        if constant == 'q5_d':
            return Constants.q5_date
        if constant == 'q8_d':
            return Constants.q8_date

    @staticmethod
    def update_constant(constant, value):
        if constant == 'q1_n':
            Constants.q1_name = value
        if constant == 'q1_c':
            Constants.q1_color = value
        if constant == 'q1_p':
            Constants.q1_plate = value
        if constant == 'q2_d':
            Constants.q2_date = value
        if constant == 'q4_n':
            Constants.q4_name = value
        if constant == 'q5_d':
            Constants.q5_date = value
        if constant == 'q8_d':
            Constants.q8_date = value


class Data:
    # Connect to DB
    conn = psycopg2.connect(f"dbname=postgres user=postgres host={db_host} port=5432 password={db_password}")
    cur = conn.cursor()

    # Dictionary with proper column names for different queries
    @staticmethod
    def get_column_names(number):
        return {
            1: ['Car ID'],
            2: ['Hour from', 'Hour to', 'Sockets occupied'],
            3: ['Morning', 'Afternoon', 'Evening'],
            4: ['Payment dates'],
            5: ['Average distance', 'Average trip duration'],
            6: ['Morning', 'Afternoon', 'Evening'],
            7: ['Car ID', 'Orders in last 3 months'],
            8: ['Customer ID', 'Total chargings'],
            9: ['Part name', 'Workshop ID', 'Parts needed'],
            10: ['Car ID', 'Average cost']
        }[number]

    # Perform query to DB and convert it to pandas dataframe
    @staticmethod
    def perform_query(number):
        if number == 6:
            return Data.q6()

        sql_file = open(f"queries/q{number}.sql", "r")
        Data.cur.execute(
            sql_file.read(),
            Constants.get_list_params(number))
        return pd.DataFrame(Data.cur.fetchall(), columns=Data.get_column_names(number))

    # Query six has pretty shitty data format to process it with pandas
    @staticmethod
    def q6():
        sql_file_morning = open("queries/q6_m.sql", "r")
        sql_file_afternoon = open("queries/q6_a.sql", "r")
        sql_file_evening = open("queries/q6_e.sql", "r")
        result = []
        Data.cur.execute(sql_file_morning.read())
        result.append(Data.cur.fetchall())
        Data.cur.execute(sql_file_afternoon.read())
        result.append(Data.cur.fetchall())
        Data.cur.execute(sql_file_evening.read())
        result.append(Data.cur.fetchall())
        df = pd.DataFrame(result).T
        df.columns = Data.get_column_names(6)
        return df


# Define Dash application
external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

# Define Dash application layout
app.layout = html.Div([
    html.H1('F18 DMD'),
    html.Br(),
    html.Div(children='Gleb Petrakov, Ali Akhmetbek'),
    html.Br(),
    html.Div(children='Choose query from dropdown menu to acquire results'),
    html.Br(),
    dcc.Dropdown(
        id='query_number_selector',
        options=[{'label': f'Query {i}', 'value': i} for i in range(1, 11)],
        value=1
    ),
    html.Br(),
    dash_table.DataTable(id='table',
                         columns=[{"name": i, "id": i} for i in Data.get_column_names(1)],
                         data=Data.perform_query(1).to_dict('rows'),
                         ),
    html.Br(),
    html.Br(),
    dcc.Dropdown(
        id='query_data_selector',
        options=[{'label': 'Query 1 customer name', 'value': 'q1_n'}, {'label': 'Query 1 car color', 'value': 'q1_c'},
                 {'label': 'Query 1 plate format', 'value': 'q1_p'},
                 {'label': 'Query 2 date', 'value': 'q2_d'}, {'label': 'Query 4 customer name', 'value': 'q4_n'},
                 {'label': 'Query 5 date', 'value': 'q5_d'}, {'label': 'Query 8 date', 'value': 'q8_d'}]
    ),
    html.Div(dcc.Input(id='query_data_input', type='text', placeholder="Value")),
    html.Button('Submit', id='query_data_submit'),
    html.Div(id='new_value'),
    html.Div(
        children='Table does not update automatically, please, reselect query after entering new data and hitting submit button')
])


# Callback for datatable column update
@app.callback(Output('table', 'columns'), [Input('query_number_selector', 'value')])
def update_columns(user_selection):
    return [{"name": i, "id": i} for i in Data.get_column_names(user_selection)]


# Callback for datatable data update
@app.callback(Output('table', 'data'), [Input('query_number_selector', 'value')])
def update_datatable(user_selection):
    return Data.perform_query(user_selection).to_dict('rows')


# Callback for current data of query selection update
@app.callback(Output('query_data_input', 'value'), [Input('query_data_selector', 'value')])
def update_data_selection(value):
    return Constants.get_constant(value)


# Button click callback
@app.callback(Output('new_value', 'children'),
              [Input('query_data_submit', 'n_clicks')],
              [dash.dependencies.State('query_data_input', 'value'),
               dash.dependencies.State('query_data_selector', 'value')])
def update_query_data(n_clicks, data_input, selector_value):
    Constants.update_constant(selector_value, data_input)
    return f'New value of {selector_value}: {data_input}'


host = '127.0.0.1'
docker_host = os.environ.get('HOST_ADDRESS')
if docker_host is not None:
    host = docker_host

port = '8050'
docker_port = os.environ.get('HOST_PORT')
if docker_port is not None:
    port = docker_port

if __name__ == '__main__':
    app.run_server(debug=False, host=host, port=port)
