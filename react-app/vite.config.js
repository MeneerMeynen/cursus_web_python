import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  // Relatieve paden zodat de build werkt onder een submap op GitHub Pages
  base: './',
})
