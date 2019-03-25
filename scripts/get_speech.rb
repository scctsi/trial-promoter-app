# Synthesizes speech from the input string of text or ssml.
# Note: ssml must be well-formed according to:
# https://www.w3.org/TR/speech-synthesis/

require "google/cloud/text_to_speech"

ENV["GOOGLE_CLOUD_KEYFILE"] = "credentials.json"

# Instantiates a client
client = Google::Cloud::TextToSpeech.new

# Set the text input to be synthesized
synthesis_input = { text: "We invite you to take part in a research study. Please take as much time as you need to read the consent form. You may want to discuss it with your family, friends, or your personal doctor. If you find any of the language difficult to understand, please ask questions. If you decide to participate, you will be asked to sign this form." }

# Build the voice request, select the language code ("en-US") and the ssml
# voice gender ("neutral")
voice = {
  language_code: "en-US",
  ssml_gender:   "FEMALE",
  name: "en-US-Wavenet-E"
}

# Select the type of audio file you want returned
audio_config = { audio_encoding: "MP3" }

# Perform the text-to-speech request on the text input with the selected
# voice parameters and audio file type
response = client.synthesize_speech synthesis_input, voice, audio_config

# The response's audio_content is binary.
File.open("output.mp3", "wb") do |file|
  # Write the response to the output file.
  file.write(response.audio_content)
end

puts "Audio content written to file 'output.mp3'"