# Data Stack Overview

This is a quick overview of the tooling and components in our data stack:

<table>
  <tbody>
    <tr>
      <th></th>
      <th>Data Platform</th>
    </tr>
    <tr>
      <td>Collection</td>
      <td>
        <ul>
          <li><a href="https://github.com/mozilla/gcp-ingestion">gcp-ingestion</a> - Mozilla's telemetry ingestion system deployed to Google Cloud Platform (GCP)
            <ul>
              <li><a href="https://docs.telemetry.mozilla.org/concepts/pipeline/gcp_data_pipeline.html">Architecture Overview</a></li>
            </ul>
          </li>
          <li>Data Sources:
            <ul>
              <li><a href="https://docs.telemetry.mozilla.org/concepts/glean/glean.html">Glean</a>  apps (including apps using glean.js)</li>
              <li>Firefox legacy telemetry clients (Firefox desktop)</li>
              <li><a href="https://docs.telemetry.mozilla.org/concepts/external_data_integration_using_fivetran.html">Fivetran</a></li>
              <li>Custom integrations</li>
              <li>Server side data</li>
            </ul>
          </li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Data Warehouse</td>
      <td>BigQuery</td>
    </tr>
    <tr>
      <td>ETL</td>
      <td>
        <ul>
          <li><a href="https://github.com/mozilla/bigquery-etl">bigquery-etl</a>
            <ul>
              <li>Internally developed tooling to create derived datasets</li>
            </ul>
          </li>
          <li><a href="https://docs.telemetry.mozilla.org/concepts/external_data_integration_using_fivetran.html">Fivetran</a>
            <ul>
              <li><a href="https://github.com/mozilla/fivetran-connectors">Custom developed connectors</a></li>
              <li>Use of <a href="https://www.fivetran.com/connectors">default connectors</a></li>
            </ul>
          </li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Orchestration</td>
      <td>
        <ul>
          <li><a href="https://github.com/mozilla/telemetry-airflow">Airflow</a>
          <ul>
            <li>Uses <a href="https://github.com/mozilla/bigquery-etl/tree/main/dags">DAGs generated via bigquery-etl</a></li>
            <li>Manually defined DAGs in <a href="https://github.com/mozilla/telemetry-airflow">telemetry-airflow</a></li>
          </ul>
          </li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Observability</td>
      <td>
        Custom tooling for data validation/data checks as part of bigquery-etl.
      </td>
    </tr>
    <tr>
      <td>Analsyis and Business Intelligence</td>
      <td>
        <ul>
          <li><a href="https://docs.telemetry.mozilla.org/introduction/tools.html#looker">Looker</a>
            <ul>
              <li>For most reporting, summaries, and ad-hoc data exploration by non-full-time-data people</li>
            </ul>
          </li>
          <li><a href="https://docs.telemetry.mozilla.org/introduction/tools.html#sqltelemetrymozillaorg-stmo">Redash</a>
            <ul>
              <li>For running ad-hoc SQL queries</li>
            </ul>
          </li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Reverse ETL</td>
      <td>None; We don’t send a lot of data out, but when we do it’s been with custom integrations, using APIs, etc.</td>
    </tr>
    <tr>
      <td>Experimentation</td>
      <td><a href="https://experimenter.info/">Nimbus/Experimenter</a></td>
    </tr>
    <tr>
      <td>Governance</td>
      <td>
        <ul>
          <li>Firefox Data Governance: Complex and designed for a specific use case that may not be generally applicable. Currently being revisited.</li>
          <li>Access Control: Support for relatively fine-grained access control at the BigQuery and Looker level, access management and approval process exists.</li>
          <li>Transparency and Docs: Automated inventory+docs: <a href="https://dictionary.telemetry.mozilla.org/">Glean Dictionary</a></li>
        </ul>
      </td>
    </tr>
    <tr>
      <td>Data Catalog</td>
      <td>
        <a href="https://mozilla.acryl.io/">Acryl</a> - for data lineage and finding data sets
      </td>
    </tr>
  </tbody>
</table>
