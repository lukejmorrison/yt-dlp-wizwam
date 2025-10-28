"""
Tests for the web API
"""
import pytest
from wizwam.web.app import create_app


@pytest.fixture
def client():
    """Create test client"""
    app = create_app()
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_health_endpoint(client):
    """Test health check endpoint"""
    response = client.get('/api/health')
    assert response.status_code == 200
    
    data = response.get_json()
    assert data['status'] == 'ok'
    assert 'version' in data


def test_plugins_endpoint(client):
    """Test plugins list endpoint"""
    response = client.get('/api/plugins')
    assert response.status_code == 200
    
    data = response.get_json()
    assert 'plugins' in data
    assert isinstance(data['plugins'], list)


def test_info_endpoint_missing_url(client):
    """Test info endpoint with missing URL"""
    response = client.post('/api/info', json={})
    assert response.status_code == 400
    
    data = response.get_json()
    assert data['success'] is False


def test_download_endpoint_missing_url(client):
    """Test download endpoint with missing URL"""
    response = client.post('/api/download', json={})
    assert response.status_code == 400
    
    data = response.get_json()
    assert data['success'] is False


def test_index_route(client):
    """Test index route returns HTML"""
    response = client.get('/')
    assert response.status_code == 200
    assert b'wizwam' in response.data
