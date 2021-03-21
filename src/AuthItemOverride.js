import React, { Component } from "react";

/**
 * override of the standard AuthItem component to provide
 * email/password login
 *
 * NOTE: we cannot use hooks here because swagger-ui depends on a version of react prior to 16
 */
export class AuthItemOverride extends Component {

  state = {
    email: '',
    password: '',
    loading: false
  }

  onClick = async () => {
    this.setState({ ...this.state, loading: true })

    try {
      const result = await fetch(`${this.props.authServer}/account/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          email: this.state.email,
          password: this.state.password
        })
      })
      const json = await result.json()

      const authPayload = {
        name: this.props.name,
        schema: this.props.schema,
        value: json.sessionToken
      }

      this.props.onAuthChange(authPayload)
      this.props.authorize({
        [authPayload.name]: authPayload
      })
    } catch (e) {
      console.error(e)
      window.alert('Error logging in.  Sure the email and password are correct?')
    } finally {
      this.setState({ email: '', password: '', loading: false })
    }
  }

  render() {
    const isAuthorized = !!this.props.authorized().get(this.props.name)
    return  (
      <div style={{ display: 'flex', flexDirection: 'column', marginBottom: '24px' }}>
        <label htmlFor="email">Email</label>
        <input
          name="email"
          type="text"
          value={this.state.email}
          onChange={e => this.setState({ ...this.state, email: e.currentTarget.value })}
          disabled={this.state.loading || isAuthorized}
        />
        <label htmlFor="password">Password</label>
        <input
          name="password"
          type="password"
          value={this.state.password}
          onChange={e => this.setState({ ...this.state, password: e.currentTarget.value })}
          disabled={this.state.loading || isAuthorized}
        />
        <button
          style={{ alignSelf: 'center', margin: '24px 0' }}
          className="btn modal-btn auth authorize"
          disabled={this.state.loading || isAuthorized}
          onClick={this.onClick}
        >
          Authorize with Email and Password
        </button>
      </div>
    )
  }
}